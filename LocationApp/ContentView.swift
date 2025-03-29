//
//  ContentView.swift
//  LocationApp
//
//  Created by Udhayanila on 28/03/25.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .alert("Enable Always Location", isPresented: $locationManager.showSettingsAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Open Settings") { locationManager.openAppSettings() }
        } message: {
            Text("To provide real-time updates, please change location access to 'Always' in Settings.")
        }
    }
}

#Preview {
    ContentView()
}

@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var showSettingsAlert = false
    @Published var lastKnownLocation: CLLocation? // Store latest location
    private let locationManager = CLLocationManager()
    
    private var previouslyAskedForAlways: Bool {
        get { UserDefaults.standard.bool(forKey: "PreviouslyAskedForAlways") }
        set { UserDefaults.standard.set(newValue, forKey: "PreviouslyAskedForAlways") }
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update only when moving 10 meters
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
                showSettingsAlert = false
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
    private func requestAlwaysIfNeeded() {
        if previouslyAskedForAlways {
            showSettingsAlert = true // Only show if the user already denied before
        } else {
            locationManager.requestAlwaysAuthorization()
            previouslyAskedForAlways = true
        }
    }
    
    /// Starts tracking user location
    private func startLocationUpdates() {
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }

    /// Handles real-time location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        lastKnownLocation = latestLocation
        print("Updated location: \(latestLocation.coordinate.latitude), \(latestLocation.coordinate.longitude)")
    }
    
    /// Opens app settings for manual location permission change
    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsURL) else { return }
        UIApplication.shared.open(settingsURL)
    }
}
