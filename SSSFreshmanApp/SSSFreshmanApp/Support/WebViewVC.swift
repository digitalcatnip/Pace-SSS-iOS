//
//  WebViewVC.swift
//  SSS Freshman App
//
//  Created by James McCarthy on 8/15/16.
//  Copyright © 2016 Digital Catnip. All rights reserved.
//


import UIKit
import WebKit

class WebViewVC: UIViewController {
    
    private var webView: WKWebView?
    var webAddress:String = "http://pace.edu"
    var titleString:String = "Pace"
    @IBOutlet var ibWebView: UIView?
    
    override func loadView() {
        webView = WKWebView()
        
        //If you want to implement the delegate
        //webView?.navigationDelegate = self
        
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = titleString
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSLog("Setting view: %@", webAddress)
        
        if let url = NSURL(string: webAddress) {
            NSLog("URL created successfully")
            let req = NSURLRequest(URL: url)
            webView?.loadRequest(req)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        registerScreen("SSS Webpage")
    }
    
    @IBAction func emailJohn() {
        EmailAction.emailSomeone("jhooker@pace.edu", message: "Hello Mr. Hooker,", subject: "From an SSS app user", presenter: self);
    }
    
    @IBAction func emailJoyce() {
        EmailAction.emailSomeone("jlau@pace.edu", message: "Hello Ms. Lau,", subject: "From an SSS app user", presenter: self)
    }
    
}
