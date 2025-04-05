//
//  ContentView.swift
//  LocationApp
//
//  Created by Udhayanila on 28/03/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    
    var body: some View {
        NavigationStack {
            DashboardView()
                .alert("Enable Always Location", isPresented: $locationManager.showSettingsAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Open Settings") { locationManager.openAppSettings() }
                } message: {
                    Text("To provide real-time updates, please change location access to 'Always' in Settings.")
                }
        }
    }
}

#Preview {
    ContentView()
}

