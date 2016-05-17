//
//  LocationManager.swift
//  LoCalendar
//
//  Created by Tyler Reardon on 4/13/16.
//  Copyright © 2016 Tyler Reardon. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit


class LocationManager: NSObject, CLLocationManagerDelegate  {
    var manager:CLLocationManager = CLLocationManager()
    var currentLocation:CLLocation = CLLocation()
    var locationLookupHandler:((location: String?) -> Void)?
    
    override init(){
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .NotDetermined, .Restricted, .Denied:
                print("No access to location services")
                manager.requestAlwaysAuthorization()
                break
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                manager.startUpdatingLocation()
                self.currentLocation = self.getGeoLocation()
                break
            }
        } else {
            print("Location services are not enabled")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .NotDetermined, .Restricted, .Denied:
                print("No access to location services")
                break
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                if let location = locations.first{
                    if let locationHandler = locationLookupHandler{
                        getAddressFromLocation(location, completion: locationHandler)
                    }
                }
                break
            }
        } else {
            print("Location services are not enabled")
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.localizedDescription)
    }
    
    //returns the user's current location
    func getGeoLocation() -> CLLocation {
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .NotDetermined, .Restricted, .Denied:
                print("No access to location services")
                break
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                manager.startUpdatingLocation()
                if let location = self.manager.location{
                    self.currentLocation = location
                }
                manager.stopUpdatingLocation()
                break
            }
        } else {
            print("Location services are not enabled")
        }
        
        return self.currentLocation
    }
    
    func getAddressFromCurrentLocation(completion: (location: String?) -> Void) {
        locationLookupHandler = completion
        manager.requestLocation()
    }
    
    func getAddressFromLocation(location: CLLocation, completion: (location: String?) -> Void) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                completion(location: nil)
                return
            }
            
            if CLLocationManager.locationServicesEnabled() {
                switch(CLLocationManager.authorizationStatus()) {
                case .NotDetermined, .Restricted, .Denied:
                    print("No access to location services")
                    break
                case .AuthorizedAlways, .AuthorizedWhenInUse:
                    if placemarks!.count > 0 {
                        let pm = placemarks![0]
                        //                print(pm.addressDictionary)      //everything
                        //                print(pm.name!)                  //address line
                        //                print(pm.locality!)              //city name
                        //                print(pm.administrativeArea!)    //state abbreviation
                        //                print(pm.postalCode!)            //zipcode
                        //                print(pm.country!)               //country
                        completion(location: "\(pm.name!) \(pm.locality!), \(pm.administrativeArea!) \(pm.postalCode!) \(pm.country!)")
                    }
                    else {
                        print("Problem with the data received from geocoder")
                        completion(location: nil)
                    }

                    break
                }
            } else {
                print("Location services are not enabled")
            }
            
         })
    }
    
    ///Sets the region of a MKMapView to fit the annotations
    func updateMapViewToFitAnnotations(map: MKMapView) {
        map.layoutMargins = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        map.showAnnotations(map.annotations, animated: true)
    }
}
