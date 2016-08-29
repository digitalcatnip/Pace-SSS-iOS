//
//  EmailAction.swift
//  Pace SSS
//
//  Created by James McCarthy on 8/29/16.
//  Copyright © 2016 Digital Catnip. All rights reserved.
//

import Foundation
import UIKit

class EmailAction {
    static func emailSomeone(address:String, message:String, subject: String, presenter: UIViewController) {
        let toEmail = address.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let subject = subject.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        let body = message.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        
        var url = NSURL(string: "ms-outlook://compose?to=\(toEmail!)&subject=\(subject!)&body=\(body!)")
        if UIApplication.sharedApplication().canOpenURL(url!) {
            UIApplication.sharedApplication().openURL(url!)
        } else {
            url = NSURL(string: "mailto:?to=\(toEmail!)?subject=\(subject!)&body=\(body!)")
            if UIApplication.sharedApplication().canOpenURL(url!) {
                UIApplication.sharedApplication().openURL(url!)
            } else {
                let alertController = UIAlertController(title: "Email Failed", message: "Could not open MS Outlook or Mail app.", preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(cancelAction)
                presenter.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
}