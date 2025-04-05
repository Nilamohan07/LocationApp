//
//  LocationManager.swift
//  LocationApp
//
//  Created by Udhayanila on 29/03/25.
//

import UIKit
import CoreLocation

@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var showSettingsAlert = false
    @Published var currentLocation: CLLocation?
    @Published var errorMessage: String?
    @Published var locationName: String?

    private let locationManager = CLLocationManager()

    /// Public computed property to check authorization status
    var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }

    /// Tracks whether the app has already requested "Always" permission
    private var previouslyAskedForAlways: Bool {
        get { UserDefaults.standard.bool(forKey: "PreviouslyAskedForAlways") }
        set { UserDefaults.standard.set(newValue, forKey: "PreviouslyAskedForAlways") }
    }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        checkInitialAuthorization()
    }

    /// Checks current authorization and requests permissions if needed
    private func checkInitialAuthorization() {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            requestAlwaysIfNeeded()
        case .authorizedAlways:
            startLocationUpdates()
        case .restricted, .denied:
            showSettingsAlert = false
        @unknown default:
            print("Unknown authorization status")
        }
    }

    /// Reacts to authorization changes dynamically
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            let status = manager.authorizationStatus
            switch status {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                showSettingsAlert = true
            case .authorizedWhenInUse:
                requestAlwaysIfNeeded()
            case .authorizedAlways:
                startLocationUpdates()
            @unknown default:
                print("Unknown authorization status")
            }
        }
    }

    /// Requests "Always" permission if the user hasn't denied it before
    func requestAlwaysIfNeeded() {
        if previouslyAskedForAlways {
            showSettingsAlert = true  // Show alert only if the user previously denied it
        } else {
            locationManager.requestAlwaysAuthorization()
            previouslyAskedForAlways = true
        }
    }

    /// Requests "When In Use" location
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    /// Starts tracking user location
    private func startLocationUpdates() {
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }

    /// Handles real-time location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        currentLocation = latestLocation
        print("Updated location: \(latestLocation.coordinate.latitude), \(latestLocation.coordinate.longitude)")

        // Reverse geocode
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(latestLocation) { [weak self] placemarks, error in
            guard let self = self else { return }
            if let placemark = placemarks?.first {
                let name = [
                    placemark.name,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ].compactMap { $0 }.joined(separator: ", ")

                DispatchQueue.main.async {
                    self.locationName = name
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    self.locationName = "Unknown location (\(error.localizedDescription))"
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        DispatchQueue.main.async {
            self.errorMessage = "Failed to get location: \(error.localizedDescription)"
        }
    }

    /// Opens app settings for manual location permission change
    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsURL) else { return }
        UIApplication.shared.open(settingsURL)
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    // Add these two methods to LocationManager
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
    }

}
