//
//  TutorTVC.swift
//  Pace SSS
//
//  Created by James McCarthy on 8/31/16.
//  Copyright © 2016 Digital Catnip. All rights reserved.
//
import GoogleAPIClient
import GTMOAuth2
import RealmSwift

class TutorTVC: UITableViewController {
    private let kKeychainItemName = "Google Sheets API"
    private let kClientID = "69356504318-0197vfcpdlkrp6m82jc3jk8i1lvvp3b3.apps.googleusercontent.com"
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = ["https://www.googleapis.com/auth/spreadsheets.readonly"]
    
    private let service = GTLService()

    private var tutors: Results<Tutor>?

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
        refresher.tintColor = UIColor.redColor()
        refresher.addTarget(self, action: #selector(showTutors), forControlEvents: .ValueChanged)
        self.refreshControl = refresher

        self.navigationController?.navigationBar.tintColor = UIColor.redColor()
        
        loadTutorsFromRealm(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
            showTutors()
        } else {
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        registerScreen("TutorScreen")
    }
    
    //MARK: UITableViewDataSource functions
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tutors != nil {
            return tutors!.count
        } else {
            return 0;
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tutorCell", forIndexPath: indexPath) as! TutorCell
        cell.tutorObj = tutors![indexPath.row]
        cell.configure()
        return cell
    }
    
    // MARK: UITableViewDelegate functions
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tutors != nil && indexPath.row < tutors!.count {
            let tutor = tutors![indexPath.row]
            sendEmailToTutor(tutor)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //MARK: Send Email
    func sendEmailToTutor(tutor: Tutor) {
        EmailAction.emailSomeone(
            tutor.email,
            message: "Hello \(tutor.first_name),\nI would like help in \(tutor.subjects).",
            subject: "From an SSS App User",
            presenter: self
        )
    }
    
    // MARK: Google Sheets API
    func showTutors() {
        NSLog("Loading from network!")
        refresher.beginRefreshing()
        let baseUrl = "https://sheets.googleapis.com/v4/spreadsheets"
        let spreadsheetId = "1BSCxHudMSLj1tDzdxFWYBqWtxDbj_Dz4jC2ZN4JiTtU"
        let courseRange = "tutor!A2:D"
        let url = String(format:"%@/%@/values/%@", baseUrl, spreadsheetId, courseRange)
        let params = ["majorDimension": "ROWS"]
        let fullUrl = GTLUtilities.URLWithString(url, queryParameters: params)
        service.fetchObjectWithURL(fullUrl,
                                   objectClass: GTLObject.self,
                                   delegate: self,
                                   didFinishSelector: #selector(TutorTVC.displayResultWithTicket(_:finishedWithObject:error:))
        )
    }
    
    func displayResultWithTicket(ticket: GTLServiceTicket, finishedWithObject object : GTLObject, error: NSError?) {
        if error != nil {
            showAlert("Network Issue", message: "Tutor information may be incorrect.")
            return
        }

        let rows = object.JSON["values"] as! [[String]]
        if rows.isEmpty {
            NSLog("No data found.")
            return
        }
        
        //Track the existing courses so we can delete removed entries
        let oldTutors = ModelManager.sharedInstance.query(Tutor.self, queryString: nil)
        var otArr = [Tutor]()
        for course in oldTutors {
            otArr.append(course)
        }
        
        var hashes = [Int]()
        var tutors = [Tutor]()
        for row in rows {
            let t = Tutor()
            t.initializeFromSpreadsheet(row)
            tutors.append(t)
            hashes.append(t.id)
        }
        //Sort the IDs of the new objects, then check to see if the old objects are in the new list
        //We'll delete any old object not in the list
        hashes.sortInPlace()
        var toDelete = [Tutor]()
        for tutor in otArr {
            if let _ = hashes.indexOf(tutor.id) {
            } else {
                toDelete.append(tutor)
            }
        }
        
        ModelManager.sharedInstance.saveModels(tutors)
        ModelManager.sharedInstance.deleteModels(toDelete)
        loadTutorsFromRealm(true)
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
    func loadTutorsFromRealm(shouldReload: Bool) {
        tutors = ModelManager.sharedInstance.query(Tutor.self, queryString: nil).sorted("first_name")
        if shouldReload {
            tableView!.reloadData()
        }
        NSLog("Done loading from realm!")
    }
}
