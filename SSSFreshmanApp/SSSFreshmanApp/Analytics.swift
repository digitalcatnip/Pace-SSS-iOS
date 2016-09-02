//
//  Analytics.swift
//  Pace SSS
//
//  Created by James McCarthy on 9/2/16.
//  Copyright © 2016 Digital Catnip. All rights reserved.
//

func initializeAnalytics() {
    // Configure tracker from GoogleService-Info.plist.
    var configureError:NSError?
    GGLContext.sharedInstance().configureWithError(&configureError)
    assert(configureError == nil, "Error configuring Google services: \(configureError)")
    
    // Optional: configure GAI options.
    let gai = GAI.sharedInstance()
    gai.trackUncaughtExceptions = true  // report uncaught exceptions
    gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release
}

func registerScreen(screenName: String) {
    let tracker = GAI.sharedInstance().defaultTracker
    tracker.set(kGAIScreenName, value: screenName)
    
    let builder = GAIDictionaryBuilder.createScreenView()
    tracker.send(builder.build() as [NSObject : AnyObject])
}

func registerButtonAction(category: String, action: String, label: String) {
    let tracker = GAI.sharedInstance().defaultTracker
    let dict = GAIDictionaryBuilder.createEventWithCategory(category, action: action, label: label, value: nil)
    tracker.send(dict.build() as [NSObject : AnyObject])
}