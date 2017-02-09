//
//  ViewController.swift
//  SunsetSunrise
//
//  Created by joy on 11/16/16.
//  Copyright © 2016 JanL. All rights reserved.
//

import UIKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var sunsetLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var locationManager = CLLocationManager()
        
        let currentLocation: CLLocation = CLLocation(latitude: 40.7128, longitude: 74.0059)
        
        // Date() - today's date - being passed in to SunsetGetter
        let sunGetter = SunsetGetter(location: currentLocation, date: Date())
        
        sunGetter.nextSunset { (sunsetTime) in
            self.sunsetLabel.text = sunsetTime
        }
        
        print("After 'nextSunset'")
        
        //self.sunsetLabel.text
    }
    
}
