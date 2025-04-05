//
//  StartTrackingView.swift
//  LocationApp
//
//  Created by Udhayanila on 05/04/25.
//

import SwiftUI
import MapKit

struct StartTrackingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = StartTrackingViewModel(locationManager: LocationManager())

    var body: some View {
        VStack(spacing: 0) {
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: viewModel.trackedLocations) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    Circle()
                        .strokeBorder(Color.blue, lineWidth: 2)
                        .frame(width: 12, height: 12)
                }
            }
            .edgesIgnoringSafeArea(.top)

            VStack(spacing: 16) {
                if let start = viewModel.startTime {
                    Text("Started at: \(formattedTime(start))")
                }

                Text("Distance: \(String(format: "%.2f", viewModel.totalDistance)) meters")
                Text("Duration: \(formattedDuration(viewModel.duration))")
                
                HStack(spacing: 20) {
                    Button(action: {
                        if viewModel.isTracking {
                            viewModel.stopTracking()
                        } else {
                            viewModel.startTracking()
                        }
                    }) {
                        Text(viewModel.isTracking ? "Stop Tracking" : "Start Tracking")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isTracking ? Color.red : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: viewModel.clearTracking) {
                        Image(systemName: "trash")
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle("Live Tracking", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }

    private func formattedDuration(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: interval) ?? ""
    }
}

#Preview {
    StartTrackingView()
}
