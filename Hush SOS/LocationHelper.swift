//
//  LocationHelper.swift
//  Hush SOS
//
//  Created by Jedda Tuuta on 6/8/2025.
//
import CoreLocation
import SwiftUI

class LocationHelper: NSObject, ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var locationText = "Getting your location..."
    @Published var hasPermission = false
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        requestPermission()
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() {
        guard hasPermission else {
            locationText = "Location permission needed"
            return
        }
        locationManager.requestLocation()
    }
    
    func getEmergencyLocationText() -> String {
        guard let location = currentLocation else {
            return "Location not available"
        }
        
        let lat = String(format: "%.6f", location.coordinate.latitude)
        let lng = String(format: "%.6f", location.coordinate.longitude)
        
        return """
        📍 EXACT LOCATION:
        Latitude: \(lat)
        Longitude: \(lng)
        Time: \(Date().formatted())
        """
    }
}

extension LocationHelper: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        DispatchQueue.main.async {
            self.currentLocation = location
            let lat = String(format: "%.4f", location.coordinate.latitude)
            let lng = String(format: "%.4f", location.coordinate.longitude)
            self.locationText = "📍 Located: \(lat), \(lng)"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.locationText = "❌ Location failed"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.hasPermission = true
                self.getCurrentLocation()
            case .denied, .restricted:
                self.hasPermission = false
                self.locationText = "❌ Location permission denied"
            case .notDetermined:
                self.hasPermission = false
                self.locationText = "⏳ Waiting for permission..."
            @unknown default:
                self.hasPermission = false
            }
        }
    }
}
