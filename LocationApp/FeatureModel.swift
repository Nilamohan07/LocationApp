//
//  FeatureModel.swift
//  LocationApp
//
//  Created by Udhayanila on 29/03/25.
//

import Foundation

struct FeatureModel: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let actionType: FeatureAction
}

enum FeatureAction: CaseIterable {
    case showCurrentLocation
    case startTracking
    case calculateDistance
    case getDirections
    case setGeofence
    case findNearbyPlaces
    case checkWeather
}
