//
//  MapVC.swift
//  Pace SSS
//
//  Created by James McCarthy on 8/19/16.
//  Copyright © 2016 Digital Catnip. All rights reserved.
//

import UIKit
import GoogleMaps

enum TileType {
    case Map
    case Earth
}

class MapsVC: UIViewController {
    let locationManager = CLLocationManager()
    let plvCampusImage = UIImage(named: "toggleplv")
    let nycCampusImage = UIImage(named: "togglenyc")
    let tileEarthImage = UIImage(named: "google_earth")
    let tileMapImage = UIImage(named: "map_pace_light")
    
    var curCampus: String = "NYC"
    var curTileType: TileType = .Map
    var locations: [String:Location] = [String:Location]()

    @IBOutlet weak var mapView:GMSMapView!
    @IBOutlet weak var campusButton:UIButton!
    @IBOutlet weak var tileButton:UIButton!

    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLocations()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        curCampus = "PLV"
        campusChanged(false)
        curTileType = .Map
        mapView.mapType = kGMSTypeNormal
        tileButton.imageView?.contentMode = .ScaleAspectFit
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
    
    func locationForCampus(campus:String) -> Location? {
        if campus == "PLV" {
            return locations["PLV_LOC"]
        } else {
            return locations["NYC_OnePacePlaza"]
        }
    }
    
    func updateButtons() {
        if curCampus == "PLV" {
            campusButton.setImage(plvCampusImage, forState: .Normal)
        } else if curCampus == "NYC" {
            campusButton.setImage(nycCampusImage, forState: .Normal)
        }
    }
    
    func updateCamera() {
        if let loc = locationForCampus(curCampus) {
            NSLog("Location found: %@, (%0.2f, %0.2f)", loc.key, loc.latitude, loc.longitude)
            let camera = GMSCameraPosition.cameraWithLatitude(loc.latitude, longitude: loc.longitude, zoom: 16.0)
            mapView.layoutIfNeeded()
            mapView.camera = camera
            mapView.myLocationEnabled = true
        }
    }
    
    func campusChanged(updateCampusButton: Bool) {
        if updateCampusButton {
            updateButtons()
        }
        updateCamera()
    }
    
    func updateCampusWithLocation(location:CLLocation) {
        let plvLoc = locationForCampus("PLV")
        let nycLoc = locationForCampus("NYC")
        if location.coordinate.latitude > plvLoc!.latitude {
            curCampus = "PLV"
        }
        else if (location.coordinate.latitude <= nycLoc!.latitude) {
            curCampus = "NYC"
        }
        
        campusChanged(false)
    }
    
    @IBAction func switchCampus() {
        if curCampus == "PLV" {
            curCampus = "NYC"
        } else if curCampus == "NYC" {
            curCampus = "PLV"
        }
        
        campusChanged(true)
    }
    
    @IBAction func swapTileType() {
        switch curTileType {
        case .Earth:
            curTileType = .Map
            mapView.mapType = kGMSTypeNormal
            tileButton.setImage(tileEarthImage, forState: .Normal)
            
        default:
            curTileType = .Earth
            mapView.mapType = kGMSTypeSatellite
            tileButton.setImage(tileMapImage, forState: .Normal)
        }
    }
}

extension MapsVC: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    // 6
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            updateCampusWithLocation(location)
            locationManager.stopUpdatingLocation()
        }
    }
}