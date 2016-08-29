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

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupButton(literacyButton)
        setupButton(academicButton)
        setupButton(eventsButton)
        setBorderRadius(johnButton)
        setBorderRadius(joyceButton)
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
        let toEmail = address.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let subject = "From an SSS app user".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let body = message.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        
        var url = NSURL(string: "ms-outlook://compose?to=\(toEmail!)&subject=\(subject!)&body=\(body!)")
        if UIApplication.sharedApplication().canOpenURL(url!) {
            UIApplication.sharedApplication().openURL(url!)
        } else {
            url = NSURL(string: "mailto:?to=\(toEmail!)?subject=\(subject!)&body=\(body)")
            if UIApplication.sharedApplication().canOpenURL(url!) {
                UIApplication.sharedApplication().openURL(url!)
            } else {
                let alertController = UIAlertController(title: "Email Failed", message: "Could not open MS Outlook or Mail app.", preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(cancelAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
 
    @IBAction func emailJohn() {
        emailSomeone("jhooker@pace.edu", message: "Hello Mr. Hooker,");
    }
    
    @IBAction func emailJoyce() {
        emailSomeone("jlau@pace.edu", message: "Hello Ms. Lau,")
    }
}
