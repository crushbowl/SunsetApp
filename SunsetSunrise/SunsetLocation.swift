//
//  SunsetLocation.swift
//  SunsetSunrise
//
//  Created by joy on 11/16/16.
//  Copyright © 2016 JanL. All rights reserved.
//

import Foundation
import CoreLocation

class SunsetLocation {
    let name: String
    let location: CLLocation
    
    init(name: String, location: CLLocation) {
        self.name = name
        self.location = location
    }
}

// What do we prefer? Non-optional or Optional?
// Non-optional is harder, but safer
// Optional is more difficult to handle - when the value 
// really is nil (empty, nothing)

