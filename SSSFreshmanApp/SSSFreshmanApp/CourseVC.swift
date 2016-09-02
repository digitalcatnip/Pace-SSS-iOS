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

class CourseVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let kKeychainItemName = "Google Sheets API"
    private let kClientID = "69356504318-0197vfcpdlkrp6m82jc3jk8i1lvvp3b3.apps.googleusercontent.com"
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = ["https://www.googleapis.com/auth/spreadsheets.readonly"]
    
    private let service = GTLService()
    private var courses: Results<Course>?
    private var alphabets = [String]()
    private var query = ""
    private var campus = "All Campuses"
    
    @IBOutlet var campusButton: UIButton?
    @IBOutlet var tableView: UITableView?
    var refresher = UIRefreshControl()


    override func viewDidLoad() {
        super.viewDidLoad()
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
            service.authorizer = auth
        }
        
        self.navigationController?.navigationBar.tintColor = UIColor.blueColor()
        
        let tableVC = UITableViewController()
        tableVC.tableView = self.tableView
        refresher = UIRefreshControl()
        refresher.tintColor = UIColor.blueColor()
        refresher.addTarget(self, action: #selector(showCourses), forControlEvents: .ValueChanged)
        tableVC.refreshControl = refresher
        
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
    
    override func viewDidAppear(animated: Bool) {
        registerScreen("CoursesScreen")
    }
    
    //MARK: UITableViewDataSource functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if courses != nil {
            return courses!.count
        } else {
            return 0;
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("courseCell", forIndexPath: indexPath) as! CourseCell
        cell.courseObj = courses![indexPath.row]
        cell.configure()
        return cell
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return alphabets
    }
    
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String,
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
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if courses != nil && indexPath.row < courses!.count {
            let course = courses![indexPath.row]
            sendEmailToJonathan(course)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Google Sheets API
    func showCourses() {
        NSLog("Loading from network!")
        refresher.beginRefreshing()
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
        if error != nil {
            showAlert("Network Issue", message: "Course information may be incorrect.")
            return
        }
        let rows = object.JSON["values"] as! [[String]]
        if rows.isEmpty {
            NSLog("No data found.")
            return
        }
        
        //Track the existing courses so we can delete removed entries
        let oldCourses = ModelManager.sharedInstance.query(Course.self, queryString: nil)
        var ocArr = [Course]()
        for course in oldCourses {
            ocArr.append(course)
        }
        
        var hashes = [Int]()
        var courses = [Course]()
        for row in rows {
            let c = Course()
            c.initializeFromSpreadsheet(row)
            courses.append(c)
            hashes.append(c.id)
        }
        //Sort the IDs of the new objects, then check to see if the old objects are in the new list
        //We'll delete any old object not in the list
        hashes.sortInPlace()
        var toDelete = [Course]()
        for course in ocArr {
            if let _ = hashes.indexOf(course.id) {
            } else {
                toDelete.append(course)
            }
        }
        
        ModelManager.sharedInstance.saveModels(courses)
        ModelManager.sharedInstance.deleteModels(toDelete)
        loadCoursesFromRealm(true)
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
    
    //MARK: Send Email
    func sendEmailToJonathan(course: Course) {
        EmailAction.emailSomeone(
            "jhooker@pace.edu",
            message: "I would like to take \(course.title).\nCRN: \(course.subject_course)",
            subject: "From an SSS App User",
            presenter: self
        )
    }
    
    // MARK: Data Management
    @IBAction func switchCampus() {
        if campus == "All Campuses" {
            campus = "New York City"
        } else if campus == "New York City" {
            campus = "Pleasantville"
        } else if campus == "Pleasantville" {
            campus = "Online"
        } else if campus == "Online" {
            campus = "All Campuses"
        }
        campusButton?.setTitle(campus, forState: .Normal)
        loadCoursesFromRealm(true)
    }
    
    func buildPredicate() -> NSPredicate? {
        var finalQuery = ""
        var setQuery = false
        var pred: NSPredicate? = nil
        if query.characters.count > 0 {
            finalQuery = "(title CONTAINS %@ or subject_desc CONTAINS %@ or subject_course CONTAINS %@)"
            setQuery = true
        }
        
        if campus != "All Campuses" && setQuery {
            finalQuery.appendContentsOf(" AND campus = %@")
            pred = NSPredicate(format: finalQuery, query, query, query, campus)
        } else if campus != "All Campuses" {
            pred = NSPredicate(format: "campus = %@", campus)
        } else if setQuery {
            pred = NSPredicate(format: finalQuery, query, query, query)
        }
        
        return pred
    }
    
    func loadCoursesFromRealm(shouldReload: Bool) {
        let pred = buildPredicate()
        courses = ModelManager.sharedInstance.query(Course.self, queryString: pred).sorted("title")
        
        alphabets = [String]()
        var letters = [String:Int]()
        for course in courses! {
            letters[course.title.substringToIndex(course.title.characters.startIndex.successor())] = 1
        }
        alphabets = Array(letters.keys).sort()
        if shouldReload {
            tableView!.reloadData()
        }
        NSLog("Done loading from realm!")
    }
}

//MARK: Text Field Delegate
extension CourseVC: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            let nsString = text as NSString
            query = nsString.stringByReplacingCharactersInRange(range, withString: string).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            loadCoursesFromRealm(true)
        }
        
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        query = ""
        loadCoursesFromRealm(true)
        return true
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

