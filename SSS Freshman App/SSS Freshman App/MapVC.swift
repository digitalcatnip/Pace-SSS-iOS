//
//  MapVC.swift
//  Pace SSS
//
//  Created by James McCarthy on 8/19/16.
//  Copyright © 2016 Digital Catnip. All rights reserved.
//

import UIKit
import GoogleMaps

class MapsVC: UIViewController {
    @IBOutlet weak var mapView:UIView?
    var locations: [String:Location] = [String:Location]()
    
    override func loadView() {
        super.loadView()
        loadLocations()
        if let loc = locations["PLV_LOC"] {
            NSLog("Location found: %@", loc.key)
            let camera = GMSCameraPosition.cameraWithLatitude(loc.latitude, longitude: loc.longitude, zoom: 16.0)
            let map = GMSMapView.mapWithFrame(mapView!.frame, camera: camera)
            map.myLocationEnabled = true
            mapView = map;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadLocations() {
        locations = [String:Location]()
        var lines = [String]()
        if let path = NSBundle.mainBundle().pathForResource("locations", ofType: "txt") {
            do {
                let text = try String(contentsOfFile: path)
                let separators = NSCharacterSet(charactersInString: "\n")
                lines = text.componentsSeparatedByCharactersInSet(separators)
                NSLog("Number of lines read: %d", lines.count)
                
            } catch {
                NSLog("Unable to read file")
            }
        }
        
        for line in lines {
            let loc = Location()
            loc.initializeFromLine(line)
            NSLog("Initialized %@", loc.key)
            locations[loc.key] = loc
        }
    }
}
