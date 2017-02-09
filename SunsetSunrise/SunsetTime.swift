//
//  SunsetTime.swift
//  SunsetSunrise
//
//  Created by joy on 11/16/16.
//  Copyright © 2016 JanL. All rights reserved.
//

import Foundation

//needs to return a time
class SunsetTime {
    var date: NSDate
    var location: SunsetLocation
    
    
    init(date: NSDate, location: SunsetLocation) {
        self.date = date
        self.location = location
    }
}

