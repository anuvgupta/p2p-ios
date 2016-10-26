//
//  Utility.swift
//  p2p
//
//  Created by Amar Ramachandran on 10/16/16.
//  Copyright © 2016 sfhacks. All rights reserved.
//

import Foundation
import CoreLocation
import Locksmith

extension Date {
    struct Formatter {
        static let iso8601: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            return formatter
        }()
    }
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}


extension String {
    var dateFromISO8601: Date? {
        return Date.Formatter.iso8601.date(from: self)
    }
}

class UtilityManager: NSObject {
    static let sharedInstance = UtilityManager()
    let locationManager = CLLocationManager()
    var location: (long: Double, lat: Double) = (0.0, 0.0)
    
    private override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func save(token: String, for user: String) {

        
        do {
            //TODO: specific username in NSDefaults
            try Locksmith.saveData(data: ["token": token], forUserAccount: user)
        } catch {
            fatalError("Unable to save token")
        }
    }
    
    func loadToken(for user: String) -> String? {
        let dictionary = Locksmith.loadDataForUserAccount(userAccount: user)
        
        
        return (dictionary!["token"] as! String?)
    }
}

extension UtilityManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] 
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        location = (long, lat)
    }
}
