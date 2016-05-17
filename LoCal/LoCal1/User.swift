//
//  User.swift
//  LoCalendar
//
//  Created by Tyler Reardon on 4/13/16.
//  Copyright © 2016 Tyler Reardon. All rights reserved.
//

import Foundation
import EventKit

class User {
    let locationManager = LocationManager()
    var username : String = String()
    var password : String = String()
    var userID : String = String()
    var sharedEvents : Dictionary = Dictionary<String,EKEvent>()
    
    init(username: String, password: String, userID: String){
        self.username = username
        self.password = password
        self.userID = userID
        locationManager.getGeoLocation()
    }
    
    func toDictionary() -> Dictionary<String,String> {
        let location = locationManager.currentLocation
        return ["username":self.username,"latitude":"\(location.coordinate.latitude)","longitude":"\(location.coordinate.longitude)"]
    }
}