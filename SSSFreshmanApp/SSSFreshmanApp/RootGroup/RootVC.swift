//
//  RootVC.swift
//  SSS Freshman App
//
//  Created by James McCarthy on 8/15/16.
//  Copyright © 2016 Digital Catnip. All rights reserved.
//

import UIKit

class RootVC: UIViewController {
    
    override func viewDidAppear(animated: Bool) {
        registerScreen("StartScreen")
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    func displayAlert(title: String, body: String) {
        let alertController = UIAlertController(title: title, message: body, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func blackBoardPressed() {
        let url = NSURL(string: "itms-apps://itunes.apple.com/us/app/blackboard-mobile-learn/id376413870")
        if UIApplication.sharedApplication().canOpenURL(url!) {
            UIApplication.sharedApplication().openURL(url!)
        } else {
            displayAlert("Failed", body: "Cannot open iTunes for Blackboard Mobile Learn")
        }
    }
    
    @IBAction func msOutlookPressed() {
        var url = NSURL(string: "ms-outlook://")
        if UIApplication.sharedApplication().canOpenURL(url!) {
            UIApplication.sharedApplication().openURL(url!)
        } else {
            url = NSURL(string: "https://itunes.apple.com/us/app/microsoft-outlook-email-calendar/id951937596")
            if UIApplication.sharedApplication().canOpenURL(url!) {
                UIApplication.sharedApplication().openURL(url!)
            } else {
                displayAlert("Failed", body: "Cannot open MS Outlook or iTunes for MS Outlook.")
            }
        }
    }
}
