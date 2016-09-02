//
//  MentorsTVC.swift
//  Pace SSS
//
//  Created by James McCarthy on 8/31/16.
//  Copyright © 2016 Digital Catnip. All rights reserved.
//

import GoogleAPIClient
import GTMOAuth2
import RealmSwift

class MentorsTVC: UITableViewController {
    private let kKeychainItemName = "Google Sheets API"
    private let kClientID = "69356504318-0197vfcpdlkrp6m82jc3jk8i1lvvp3b3.apps.googleusercontent.com"
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = ["https://www.googleapis.com/auth/spreadsheets.readonly"]
    
    private let service = GTLService()
    
    private var mentors: Results<Mentor>?
    
    var refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
            service.authorizer = auth
        }
        
        refresher = UIRefreshControl()
        refresher.tintColor = UIColor.blueColor()
        refresher.addTarget(self, action: #selector(showMentors), forControlEvents: .ValueChanged)
        self.refreshControl = refresher

        self.navigationController?.navigationBar.tintColor = UIColor(red: 39/255, green: 85/255, blue: 235/255, alpha: 1.0)
        
        loadMentorsFromRealm(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
            showMentors()
        } else {
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        registerScreen("MentorScreen")
    }
    
    //MARK: UITableViewDataSource functions
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mentors != nil {
            return mentors!.count
        } else {
            return 0;
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mentorCell", forIndexPath: indexPath) as! MentorCell
        cell.mentorObj = mentors![indexPath.row]
        cell.configure()
        return cell
    }
    
    // MARK: UITableViewDelegate functions
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if mentors != nil && indexPath.row < mentors!.count {
            let mentor = mentors![indexPath.row]
            sendEmailToMentor(mentor)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //MARK: Send Email
    func sendEmailToMentor(mentor: Mentor) {
        EmailAction.emailSomeone(
            mentor.email,
            message: "Hello \(mentor.first_name),",
            subject: "From an SSS App User",
            presenter: self
        )
    }
    
    // MARK: Google Sheets API
    func showMentors() {
        NSLog("Loading from network!")
        refresher.beginRefreshing()
        let baseUrl = "https://sheets.googleapis.com/v4/spreadsheets"
        let spreadsheetId = "1njPTxjoLI2c2QpQdBv11Q9YOxTRYZKxs0WEAgwg96PI"
        let courseRange = "Mentors!A2:E"
        let url = String(format:"%@/%@/values/%@", baseUrl, spreadsheetId, courseRange)
        let params = ["majorDimension": "ROWS"]
        let fullUrl = GTLUtilities.URLWithString(url, queryParameters: params)
        service.fetchObjectWithURL(fullUrl,
                                   objectClass: GTLObject.self,
                                   delegate: self,
                                   didFinishSelector: #selector(MentorsTVC.displayResultWithTicket(_:finishedWithObject:error:))
        )
    }
    
    func displayResultWithTicket(ticket: GTLServiceTicket, finishedWithObject object : GTLObject, error: NSError?) {
        if error != nil {
            showAlert("Network Issue", message: "Mentor information may be incorrect.")
            NSLog("Got network error: %@", error!.localizedDescription)
            return
        }

        let rows = object.JSON["values"] as! [[String]]
        if rows.isEmpty {
            NSLog("No data found.")
            return
        }
        
        //Track the existing courses so we can delete removed entries
        let oldMentors = ModelManager.sharedInstance.query(Mentor.self, queryString: nil)
        var otArr = [Mentor]()
        for course in oldMentors {
            otArr.append(course)
        }
        
        var hashes = [Int]()
        var mentors = [Mentor]()
        for row in rows {
            let t = Mentor()
            t.initializeFromSpreadsheet(row)
            mentors.append(t)
            hashes.append(t.id)
        }
        //Sort the IDs of the new objects, then check to see if the old objects are in the new list
        //We'll delete any old object not in the list
        hashes.sortInPlace()
        var toDelete = [Mentor]()
        for mentor in otArr {
            if let _ = hashes.indexOf(mentor.id) {
            } else {
                toDelete.append(mentor)
            }
        }
        
        ModelManager.sharedInstance.saveModels(mentors)
        ModelManager.sharedInstance.deleteModels(toDelete)
        loadMentorsFromRealm(true)
        refresher.endRefreshing()
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
    func loadMentorsFromRealm(shouldReload: Bool) {
        mentors = ModelManager.sharedInstance.query(Mentor.self, queryString: nil).sorted("first_name")
        if shouldReload {
            tableView!.reloadData()
        }
        NSLog("Done loading from realm!")
    }
}
