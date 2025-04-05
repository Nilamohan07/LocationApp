//
//  DashboardViewModel.swift
//  LocationApp
//
//  Created by Udhayanila on 29/03/25.
//

import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    @Published var features: [FeatureModel] = []

    init() {
        loadFeatures()
    }

    func loadFeatures() {
        features = [
            FeatureModel(title: "Show My Location", icon: "location.fill", actionType: .showCurrentLocation),
            FeatureModel(title: "Start Tracking", icon: "map", actionType: .startTracking),
            FeatureModel(title: "Calculate Distance", icon: "arrow.triangle.branch", actionType: .calculateDistance),
            FeatureModel(title: "Get Directions", icon: "car.fill", actionType: .getDirections),
            FeatureModel(title: "Set Up Geofence", icon: "bell.circle.fill", actionType: .setGeofence),
            FeatureModel(title: "Find Nearby Places", icon: "fork.knife.circle.fill", actionType: .findNearbyPlaces),
            FeatureModel(title: "Check Weather", icon: "cloud.sun.fill", actionType: .checkWeather)
        ]
    }

    func handleFeatureAction(_ action: FeatureAction) {
        switch action {
        case .showCurrentLocation:
            print("Fetching current location...")
        case .startTracking:
            print("Starting location tracking...")
        case .calculateDistance:
            print("Calculating distance...")
        case .getDirections:
            print("Getting directions...")
        case .setGeofence:
            print("Setting up a geofence...")
        case .findNearbyPlaces:
            print("Finding nearby places...")
        case .checkWeather:
            print("Fetching weather details...")
        }
    }
}
