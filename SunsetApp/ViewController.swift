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
    //var requestURL = String()
    var currentLocation: CLLocation?
    
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
        
        //  Dropdown of selection of cities
        //  Type in the city name
        //  Choose it on a map (mapkit)
        //  CLLocation (geolocation) -- immediate location - scale
        
        //  Error handling - tell the user they entered URL info that was not correct.
        
        
        locationManager.startUpdatingLocation()
        //        findSunsetTime()
        
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.first
        //returns an array of CLLocations
        if let location = locations.first where location.horizontalAccuracy < 1000 && location.verticalAccuracy < 1000 {
            reverseGeocode(location)
            locationManager.stopUpdatingLocation()
            self.findSunsetTime(location)
        } else {
            print("I'm waiting for a more accurate location.")
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
    
    
    func findSunsetTime() {
        
        var currentLocation = CLLocation()
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
            
            
            if let unwrappedLocation = self.currentLocation {
                currentLocation = unwrappedLocation
                findSunsetTime(currentLocation)
                return
            }
            
        }
        //FIXME: Handle Error
    }
    
    func findSunsetTime(location: CLLocation, date: NSDate = NSDate()) {
        findSunsetTime(location, date: date, completionHandler: { (dataThatComesBackFromTheInternet, httpResponse, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if let unwrappedDataThatComesBackFromTheInternet = dataThatComesBackFromTheInternet {
                    
                    do {
                        let serverTimeString = try self.serverTimeString(from: unwrappedDataThatComesBackFromTheInternet)
                        let serverTimeStringComplete = self.serverTimeStringForTestingWithAug13(serverTimeString)
                        
                        let sunsetDate =  try self.date(fromCompleteServerTime: serverTimeStringComplete)
                        
                        let sunsetUserFacingString = self.userFacingTime(from: sunsetDate)
                        self.outputLabel.text = sunsetUserFacingString
                        
                    }  catch let error as NSError {
                        print("\(error.localizedDescription)")
                    }
                } else {
                    print("data is nil")
                }
            })
        })
    }
    
    func findSunsetTime(location: CLLocation, date: NSDate, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
        
        //    http://api.sunrise-sunset.org/json?lat=36.7201600&lng=-4.4203400
        
        let baseURL = "http://api.sunrise-sunset.org/json?"
        let latitude: String = "\(location.coordinate.latitude)"
        let longitude: String = "\(location.coordinate.longitude)"
        //        var myToday: String =
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = NSTimeZone(name:"UTC")
        let date = dateFormatter.dateFromString("2016-08-13")
        
        
        
        let dateQueryStringValue = dateFormatter.stringFromDate(date!)
        
        let requestURL =  (baseURL) + ("lat="+latitude) + ("&lng="+longitude) + ("&date="+"2016-08-13")
        
        let url = NSURL(string:requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: completionHandler)
        task.resume()
        
    }
    
    func serverQueryString (from date: NSDate) -> String {
        
        
        
        return "String"
    }
    
    
    func serverTimeString(from data: NSData) throws -> String {
        
        let jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        if let correctlyTypedSunsetResults = jsonObject as? [String:AnyObject] {
            
            self.sunsetTimes = correctlyTypedSunsetResults // Dictionary<String,AnyObject>
            
            if let item = correctlyTypedSunsetResults["results"] as? [String: AnyObject] {
                if let confirmedString = item["sunset"] as? String {
                    print(confirmedString)
                    return confirmedString
                }
            }
        }
        throw NSError(domain: "com.JanelleRocks", code: 1, userInfo: [NSLocalizedDescriptionKey:"Problem converting json object to serverTimeString"])
    }
    
    
    func serverTimeStringForTestingWithAug13(serverTime: String) -> String {
            return "2016-08-13T" + serverTime
        
    }

    func date(fromCompleteServerTime string: String) throws -> NSDate {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss a"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        
        //if this is true 'keep going', else do what's in the block
        guard let date = formatter.dateFromString(string) else {
            throw NSError(domain: "com.janlRocks", code: 1, userInfo: [NSLocalizedDescriptionKey: "Our formatter didn't convert to a date from \(string) with format \(formatter.dateFormat)"])
        }
        
        return date
    }
    
    func userFacingTime(from date: NSDate) -> String {
        
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .NoStyle
        formatter.timeZone = NSTimeZone.defaultTimeZone()
        
        let userFacingString = formatter.stringFromDate(date)
        return userFacingString
    
    }

}

