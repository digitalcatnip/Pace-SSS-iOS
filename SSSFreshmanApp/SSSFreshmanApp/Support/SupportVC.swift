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
//        setBorderRadius(johnButton)
//        setBorderRadius(joyceButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "academicSegue"
        {
            if let destinationVC = segue.destinationViewController as? WebViewVC {
                destinationVC.webAddress = "https://drive.google.com/file/d/0B35gGagDNpQBUVdMSy1HTTF0WWM/view?usp=sharing"
                destinationVC.titleString = "Academic Services"
            }
        }
        else if segue.identifier == "financialSegue"
        {
            if let destinationVC = segue.destinationViewController as? WebViewVC {
                destinationVC.webAddress = "https://drive.google.com/file/d/0B35gGagDNpQBTDFEc0JJU2dmWFE/view?usp=sharing"
                destinationVC.titleString = "Financial Counseling"
            }
        }
        else if segue.identifier == "culturalSegue"
        {
            if let destinationVC = segue.destinationViewController as? WebViewVC {
                destinationVC.webAddress = "http://www.pace.edu/dyson/centers/center-for-undergraduate-research-experiences/student-support-services#socialandculturalevents"
                destinationVC.titleString = "Cultural Events"
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
     
    @IBAction func emailJohn() {
        EmailAction.emailSomeone("jhooker@pace.edu", message: "Hello Mr. Hooker,", subject: "From an SSS app user", presenter: self);
    }
    
    @IBAction func emailJoyce() {
        EmailAction.emailSomeone("jlau@pace.edu", message: "Hello Ms. Lau,", subject: "From an SSS app user", presenter: self)
    }
}
