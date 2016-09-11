//
//  CalendarVC.swift
//  Pace SSS
//
//  Created by James McCarthy on 8/31/16.
//  Copyright © 2016 Digital Catnip. All rights reserved.
//
import GoogleAPIClient
import GTMOAuth2
import RealmSwift

class CalendarVC: UIViewController {
    private let kKeychainItemName = "SSS Freshman App Cal"
    private let kClientID = "1071382956425-khatsf83p2hm5oihev02j2v36q5je8r8.apps.googleusercontent.com"
    private let kCalendarID = "kd0jfkn4qikqq9fajturdappqc@group.calendar.google.com";  //SSS cal ID

    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLAuthScopeCalendarReadonly]
    private let service = GTLServiceCalendar()
    
    private var calEvents: Results<CalEvent>? // Events for entire calendar
    private var todayEvents: Results<CalEvent>? // Events for selected date
    private var currentDate: NSDate = NSCalendar.currentCalendar().startOfDayForDate(NSDate())
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var calendarView: FSCalendar?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
            service.authorizer = auth
        }
        self.tableView?.hidden = true
        self.navigationController?.navigationBar.tintColor = UIColor(red: 33/255, green: 66/255, blue: 119/255, alpha: 1.0)
    }
    
    override func viewDidAppear(animated: Bool) {
        registerScreen("Calendar")
        loadAllEventsFromRealm(true)
        loadTodaysEventsFromRealm(true)
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
            fetchEvents()
        } else {
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }
    
    //MARK: Google Calendar API
    // Construct a query and get a list of upcoming events from the user calendar
    func fetchEvents() {
        let query = GTLQueryCalendar.queryForEventsListWithCalendarId(kCalendarID)
        query.maxResults = 100
        query.timeMin = GTLDateTime(date: NSDate().dateByAddingTimeInterval(86400*30 * -1), timeZone: NSTimeZone.localTimeZone())
        query.singleEvents = true
        query.orderBy = kGTLCalendarOrderByStartTime
        service.executeQuery(
            query,
            delegate: self,
            didFinishSelector: #selector(CalendarVC.displayResultWithTicket(_:finishedWithObject:error:))
        )
    }
    
    // Display the start dates and event summaries in the UITextView
    func displayResultWithTicket(
        ticket: GTLServiceTicket,
        finishedWithObject response : GTLCalendarEvents,
                           error : NSError?) {
        
        if error != nil {
            showAlert("Network Issue", message: "Events on the calendar may not be up to date.")
            return
        }
        
        let oldEvents = ModelManager.sharedInstance.query(CalEvent.self, queryString: nil)
        var oeArr = [CalEvent]()
        for event in oldEvents {
            oeArr.append(event)
        }
        
        if let events = response.items() where !events.isEmpty {
            var eventIDs = [String:Int]()
            var calEvents = [CalEvent]()
            for event in events as! [GTLCalendarEvent] {
                let newCE = CalEvent()
                newCE.initializeFromGoogle(event)
                eventIDs[newCE.event_id] = 1
                calEvents.append(newCE)
            }
            
            var toDelete = [CalEvent]()
            for event in oeArr {
                if let _ = eventIDs[event.event_id] {
                } else if event.start_time.compare(NSDate()) == .OrderedDescending {
                    toDelete.append(event)
                }
            }
            ModelManager.sharedInstance.deleteModels(toDelete)
            ModelManager.sharedInstance.saveModels(calEvents)
        } else {
            NSLog("No events found.")
        }
        loadTodaysEventsFromRealm(true)
        loadAllEventsFromRealm(true)
    }
    
    // Creates the auth controller for authorizing access to Google Calendar API
    private func createAuthController() -> GTMOAuth2ViewControllerTouch {
        let scopeString = scopes.joinWithSeparator(" ")
        return GTMOAuth2ViewControllerTouch(
            scope: scopeString,
            clientID: kClientID,
            clientSecret: nil,
            keychainItemName: kKeychainItemName,
            delegate: self,
            finishedSelector: #selector(CalendarVC.viewController(_:finishedWithAuth:error:))
        )
    }
    
    // Handle completion of the authorization process, and update the Google Calendar API
    // with the new credentials.
    func viewController(vc : UIViewController,
                        finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?) {
        
        if let error = error {
            service.authorizer = nil
            showAlert("Authentication Error", message: error.localizedDescription)
            return
        }
        
        service.authorizer = authResult
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.Default,
            handler: nil
        )
        alert.addAction(ok)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: Data Management methods
    func predicateForDate(date: NSDate) -> NSPredicate {
        let startDate = NSCalendar.currentCalendar().startOfDayForDate(date.dateByAddingTimeInterval(86400))
        let endDate = NSCalendar.currentCalendar().startOfDayForDate(date.dateByAddingTimeInterval(86400*2))
        return NSPredicate(format: "start_time >= %@ AND start_time <= %@", startDate, endDate)
    }
    
    func loadTodaysEventsFromRealm(reload: Bool) {
        let pred = predicateForDate(currentDate)
        todayEvents = ModelManager.sharedInstance.query(CalEvent.self, queryString: pred).sorted("start_time")
        if reload {
            if todayEvents!.count > 0 {
                self.tableView!.hidden = false
                self.tableView!.reloadData()
                todayEvents?.forEach() { event in
                    registerButtonAction("Calendar", action: "Event Viewed", label: event.title)
                }
            } else {
                self.tableView!.hidden = true
            }
        }
    }
    
    func loadAllEventsFromRealm(reload: Bool) {
        calEvents = ModelManager.sharedInstance.query(CalEvent.self, queryString: nil)
        if reload {
            self.calendarView?.reloadData()
        }
    }
}

//MARK: Calendar Methods
extension CalendarVC: FSCalendarDataSource, FSCalendarDelegate {
    func calendar(calendar: FSCalendar, numberOfEventsForDate date: NSDate) -> Int {
        let pred = predicateForDate(date)
        let results = ModelManager.sharedInstance.query(CalEvent.self, queryString: pred)
        return results.count
    }
    
    func calendar(calendar: FSCalendar, didSelectDate date: NSDate) {
        currentDate = date
        loadTodaysEventsFromRealm(true)
    }
}

//MARK: Table Methods
extension CalendarVC: UITableViewDelegate, UITableViewDataSource {
    //MARK: UITableViewDataSource functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if todayEvents != nil {
            return todayEvents!.count
        } else {
            return 0;
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if todayEvents != nil {
            let event = todayEvents![indexPath.row]
            if event.desc.characters.count < 1 {
                return 90.0
            }
        }
        return 150.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as! CalEventCell
        cell.eventObj = todayEvents![indexPath.row]
        cell.configure()
        return cell
    }
    
    // MARK: UITableViewDelegate functions
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}