//
//  SupportVC.swift
//  SSS Freshman App
//
//  Created by James McCarthy on 8/15/16.
//  Copyright © 2016 Digital Catnip. All rights reserved.
//

import UIKit
import MessageUI

class SupportVC: UIViewController {
    
    @IBOutlet var literacyButton:UIButton?
    @IBOutlet var academicButton:UIButton?
    @IBOutlet var eventsButton:UIButton?
    @IBOutlet var johnButton:UIButton?
    @IBOutlet var joyceButton:UIButton?
    @IBOutlet var normaButton:UIButton?
    @IBOutlet var mariaButton:UIButton?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupButton(literacyButton)
        setupButton(academicButton)
        setupButton(eventsButton)
        setBorderRadius(johnButton)
        setBorderRadius(joyceButton)
        setBorderRadius(normaButton)
        setBorderRadius(mariaButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "academicSegue"
        {
            if let destinationVC = segue.destinationViewController as? WebViewVC {
                destinationVC.webAddress = "http://www.pace.edu/dyson/centers/center-for-undergraduate-research-experiences/student-support-services#eli"
                destinationVC.titleString = "Academic Services"
            }
        }
    }

    func setupButton(button: UIButton?) {
        button?.titleLabel?.numberOfLines = 1;
        button?.titleLabel?.adjustsFontSizeToFitWidth = true;
        button?.titleLabel?.lineBreakMode = NSLineBreakMode.ByClipping;
    }
    
    func setBorderRadius(button: UIButton?) {
        if button != nil {
            let width = button!.frame.width
            button!.clipsToBounds = true
            button!.layer.cornerRadius = width / 2.0;
        }
    }
    
    func emailSomeone(address:String, message:String) {
        let toEmail = address
        let subject = "From an SSS app user".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let body = message.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        
        let urlString = "mailto:\(toEmail)?subject=\(subject)&body=\(body)"
        if let url = NSURL(string:urlString) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
 
    @IBAction func emailJohn() {
        emailSomeone("jhooker@pace.edu", message: "Hello Mr. Hooker,");
    }
}
