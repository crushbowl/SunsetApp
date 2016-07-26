//
//  ViewController.swift
//  SunsetApp
//
//  Created by joy on 7/16/16.
//  Copyright © 2016 JanL. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var outputLabel: UILabel!
    var locationManager = CLLocationManager()
    var requestURL = String()
    
    // Array<Dictionary<String,AnyObject>>
    // Dictionary<String,AnyObject>()

    //   var myResult = response.first <<array
    //   var sunsetTimes:Dictionary<String, AnyObject>? // sunsetTimes *can be nil* ?<==
    var sunsetTimes :Dictionary<String, AnyObject>?// = Dictionary<String, AnyObject>() // sunsetTimes is *not nil*, never be nil, type is inferred (whatever we set it equal to), cannot reset to some other type

    //    can be nil -- can not be nil --- never be nil (better) than if it *can* be nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        
        
        //        Dropdown of selection of cities
        //        Type in the city name
        //        Choose it on a map (mapkit)
        //        CLLocation (geolocation) -- immediate location - scale
        
        //        Error handling - tell the user they entered URL info that was not correct.
        
        let url = NSURL(string:requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!) { (dataThatComesBackFromTheInternet, httpResponse, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if let unwrappedDataThatComesBackFromTheInternet = dataThatComesBackFromTheInternet {
                    do {
                        if let correctlyTypedSunsetResults = try NSJSONSerialization.JSONObjectWithData(unwrappedDataThatComesBackFromTheInternet, options: .AllowFragments)  as? [String:AnyObject] {
                            self.sunsetTimes = correctlyTypedSunsetResults // Dictionary<String,AnyObject>
                            
                            if (correctlyTypedSunsetResults["results"] as? [String: AnyObject]) != nil {
                                let item = correctlyTypedSunsetResults["results"] as? [String: AnyObject]
                                self.outputLabel.text = item?["sunset"] as? String
                            }
                        } else {
                            print("There is a problem")
                        }
                    }  catch let error as NSError {
                        print("JSONError: \(error.localizedDescription)")
                    }
                } else {
                    print("data is nil")
                }
            })
        }
        task.resume()
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first //returns an array of CLLocations
        if location?.horizontalAccuracy < 1000 && location?.verticalAccuracy < 1000 {
            reverseGeocode(location!)
            locationManager.stopUpdatingLocation()
        }
        
    }
    
    func reverseGeocode (location: CLLocation ) {
        let geoCode = CLGeocoder()
        geoCode.reverseGeocodeLocation(location) { (placemarks:[CLPlacemark]?, error: NSError?) in
            let placemark = placemarks?.first
            if let subthoroughfare = placemark?.subThoroughfare {
                let address = "\(subthoroughfare) \(placemark?.thoroughfare)\n \(placemark?.locality)"
                print (address)
                
            } else {
                print("No subthoroughfare")
            }
        }
    }
    
    
    @IBAction func onCurrentLocationPressed(sender: UIButton) {
        
        locationManager.startUpdatingLocation()
        findSunsetTime()
    }
    
    
    func findSunsetTime(/*location: CLLocation*/) {
        
        var currentLocation = CLLocation()
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
            
            currentLocation = locationManager.location!
        }
        
        
        let date = NSDate() // - find the local/current date and time
        //    http://api.sunrise-sunset.org/json?lat=36.7201600&lng=-4.4203400
        
        let baseURL = "http://api.sunrise-sunset.org/json?"
        let latitude: String = "\(currentLocation.coordinate.longitude)"
        let longitude: String = "\(currentLocation.coordinate.latitude)"
        //        var myToday: String =
        let requestURL =  (baseURL) + ("lat="+latitude) + ("&lng="+longitude) //+ (myToday)
        
        
        
    }
    
    
}

