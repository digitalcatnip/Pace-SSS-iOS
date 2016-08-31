//
//  CourseVC.swift
//  Pace SSS
//
//  Created by James McCarthy on 8/31/16.
//  Copyright © 2016 Digital Catnip. All rights reserved.
//

import GoogleAPIClient
import GTMOAuth2
import RealmSwift

class CourseVC: UITableViewController {
    private let kKeychainItemName = "Google Sheets API"
    private let kClientID = "69356504318-0197vfcpdlkrp6m82jc3jk8i1lvvp3b3.apps.googleusercontent.com"
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = ["https://www.googleapis.com/auth/spreadsheets.readonly"]
    
    private let service = GTLService()
    private var courses: Results<Course>?
    private var alphabets = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
            service.authorizer = auth
        }
        
        loadCoursesFromRealm(false)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
            showCourses()
        } else {
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }
    
    //MARK: UITableViewDataSource functions

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if courses != nil {
            return courses!.count
        } else {
            return 0;
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("contactCell", forIndexPath: indexPath) as! PhoneNumberCell
//        cell.contactObj = contacts[indexPath.row]
//        cell.configure()
//        return cell
//    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return alphabets
    }
    
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String,
                            atIndex index: Int) -> Int {
        if courses != nil {
            for i in 0..<courses!.count {
                let course = courses![i]
                let s = course.title.substringToIndex(course.title.characters.startIndex.successor())
                if s == title {
                    tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0), atScrollPosition: .Top, animated: true)
                    break
                }
            }
        }
        return -1
    }
    
    // MARK: UITableViewDelegate functions
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Google Sheets API
    func showCourses() {
        let baseUrl = "https://sheets.googleapis.com/v4/spreadsheets"
        let spreadsheetId = "1mtFnkamBkyWKZZRO4AXdz9azL5TkRjCyHuOknvDkJMI"
        let courseRange = "Courses!A2:E"
        let url = String(format:"%@/%@/values/%@", baseUrl, spreadsheetId, courseRange)
        let params = ["majorDimension": "ROWS"]
        let fullUrl = GTLUtilities.URLWithString(url, queryParameters: params)
        service.fetchObjectWithURL(fullUrl,
                                   objectClass: GTLObject.self,
                                   delegate: self,
                                   didFinishSelector: #selector(CourseVC.displayResultWithTicket(_:finishedWithObject:error:))
        )
    }
    
    func displayResultWithTicket(ticket: GTLServiceTicket, finishedWithObject object : GTLObject, error: NSError?) {
        let rows = object.JSON["values"] as! [[String]]
        if rows.isEmpty {
            NSLog("No data found.")
            return
        }
        
        var courses = [Course]()
        for row in rows {
            let c = Course()
            c.initializeFromSpreadsheet(row)
            courses.append(c)
        }
        ModelManager.sharedInstance.saveModels(courses)
        loadCoursesFromRealm(true)
    }
    
    private func createAuthController() -> GTMOAuth2ViewControllerTouch {
        let scopeString = scopes.joinWithSeparator(" ")
        return GTMOAuth2ViewControllerTouch(
            scope: scopeString,
            clientID: kClientID,
            clientSecret: nil,
            keychainItemName: kKeychainItemName,
            delegate: self,
            finishedSelector: #selector(CourseVC.viewController(_:finishedWithAuth:error:))
        )
    }
    
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
    
    // MARK: Data Management
    func loadCoursesFromRealm(shouldReload: Bool) {
        courses = ModelManager.sharedInstance.query(Course.self, queryString: nil) as! Results<Course>
        alphabets = [String]()
        var letters = [String:Int]()
        for course in courses! {
            letters[course.title.substringToIndex(course.title.characters.startIndex.successor())] = 1
        }
        alphabets = Array(letters.keys).sort()
        if shouldReload {
            self.tableView.reloadData()
        }
    }
}
