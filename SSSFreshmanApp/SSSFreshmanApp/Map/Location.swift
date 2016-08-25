//
//  Location.swift
//  Pace SSS
//
//  Created by James McCarthy on 8/22/16.
//  Copyright © 2016 Digital Catnip. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import GoogleMaps

class MarkerIcons: NSObject {
    static var images: [String:UIImage] = [String:UIImage]()
    
    static func getImageForMarker(icon: String) -> UIImage? {
        if let image = images[icon] {
            return image
        } else {
            let image = UIImage(named: icon)
            images[icon] = image
            return image
        }
    }
}

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
        if let lat = CLLocationDegrees(components[2]) {
            latitude = lat
        }
        if let lon = CLLocationDegrees(components[1]) {
            longitude = lon
        }
        if(components.count > 3) {
            title = components[3]
            descrip = components[4]
            icon = components[5]
        }
    }
    
    func addToMap(mapView: GMSMapView) {
        if title.characters.count == 0 {
            return
        }
        let position = CLLocationCoordinate2DMake(latitude, longitude)
        let marker = GMSMarker(position: position)
        marker.title = title
        marker.snippet = descrip
        marker.icon = MarkerIcons.getImageForMarker(icon)
        marker.map = mapView
    }
}