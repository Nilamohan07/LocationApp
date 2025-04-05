//
//  FeatureModel.swift
//  LocationApp
//
//  Created by Udhayanila on 29/03/25.
//

import Foundation
import CoreLocation

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

struct IdentifiableLocation: Identifiable, Equatable {
    let id = UUID()
    let location: CLLocation
    
    var coordinate: CLLocationCoordinate2D {
        location.coordinate
    }
}
