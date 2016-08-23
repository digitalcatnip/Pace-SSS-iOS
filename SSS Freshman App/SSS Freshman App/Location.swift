//
//  Location.swift
//  Pace SSS
//
//  Created by James McCarthy on 8/22/16.
//  Copyright © 2016 Digital Catnip. All rights reserved.
//

import Foundation
import CoreLocation

class Location: NSObject {
    var key:String = ""
    var latitude:CLLocationDegrees = 0.0
    var longitude:CLLocationDegrees = 0.0
    var title:String = ""
    var descrip:String = ""
    var icon:String = ""
    
    func initializeFromLine(line:String) {
        let components = line.componentsSeparatedByString("|")
        key = components[0]
        if let lat = CLLocationDegrees(components[1]) {
            latitude = lat
        }
        if let lon = CLLocationDegrees(components[2]) {
            longitude = lon
        }
        if(components.count > 3) {
            title = components[3]
            descrip = components[4]
            icon = components[5]
        }
    }
}