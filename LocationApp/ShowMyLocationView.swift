//
//  ShowMyLocationView.swift
//  LocationApp
//
//  Created by Udhayanila on 03/04/25.
//

import SwiftUI
import MapKit

struct ShowMyLocationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default: San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005) // Precise zoom
    )

    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left") // Back arrow
                }
                .frame(width: 20)
                Spacer()
                Text("My Location")
                    .fontWeight(.bold)
                    .font(.title2)
                Spacer()
                Spacer()
                    .frame(width: 20)
            }
            .frame(height: 20)
            Map(coordinateRegion: $region, showsUserLocation: true)
                .edgesIgnoringSafeArea(.all)

            if let name = locationManager.locationName {
                Text(name)
                    .padding()
            } else {
                Text("Fetching location...")
                    .foregroundColor(.gray)
                    .padding()
            }

            // Show button only if authorization is not given
            if locationManager.authorizationStatus == .notDetermined ||
                locationManager.authorizationStatus == .denied {
                Button("Allow Location Access") {
                    locationManager.requestLocation()
                    locationManager.requestAlwaysIfNeeded()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
        }
        .navigationBarBackButtonHidden(true)
        .onReceive(locationManager.$currentLocation) { location in
            if let location = location {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002) // Even closer zoom
                )
            }
        }
        .alert("Enable Always Location", isPresented: $locationManager.showSettingsAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Open Settings") { locationManager.openAppSettings() }
        } message: {
            Text("To provide real-time updates, please change location access to 'Always' in Settings.")
        }
    }
}

#Preview {
    ShowMyLocationView()
}
