//
//  StartTrackingViewModel.swift
//  LocationApp
//
//  Created by Udhayanila on 05/04/25.
//

import Foundation
import CoreLocation
import Combine
import MapKit

@MainActor
class StartTrackingViewModel: ObservableObject {
    @Published var trackedLocations: [IdentifiableLocation] = []
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )
    @Published var isTracking = false
    @Published var startTime: Date?
    @Published var totalDistance: CLLocationDistance = 0
    @Published var duration: TimeInterval = 0
    private var timer: Timer?

    private var cancellables = Set<AnyCancellable>()
    private let locationManager: LocationManager
    private var lastLocation: CLLocation?

    init(locationManager: LocationManager) {
        self.locationManager = locationManager

        locationManager.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                guard let self else { return }
                
                if self.startTime == nil {
                    self.startTime = Date()
                }

                if let last = self.lastLocation {
                    let distance = location.distance(from: last)
                    self.totalDistance += distance
                }

                self.lastLocation = location
                self.duration = Date().timeIntervalSince(self.startTime ?? Date())
                self.trackedLocations.append(IdentifiableLocation(location: location))
                self.region.center = location.coordinate
            }
            .store(in: &cancellables)
    }
    
    func startTracking() {
        isTracking = true
        locationManager.startUpdatingLocation()
        startTime = Date()
        totalDistance = 0
        duration = 0
        lastLocation = nil

        // Start a repeating timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.duration = Date().timeIntervalSince(startTime)
        }
    }

    func stopTracking() {
        isTracking = false
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil
    }

    func clearTracking() {
        trackedLocations.removeAll()
        totalDistance = 0
        duration = 0
        startTime = nil
        lastLocation = nil
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
    
    deinit {
        timer?.invalidate()
    }
}
