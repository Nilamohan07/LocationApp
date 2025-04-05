//
//  DashboardView.swift
//  LocationApp
//
//  Created by Udhayanila on 29/03/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State var selectedAction: FeatureAction?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Location Dashboard")
                        .font(.largeTitle).bold()
                        .padding(.horizontal)

                    GeometryReader { geometry in
                        let columns = adaptiveColumns(for: geometry.size.width)
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.features) { feature in
                                Button(action: {
                                    viewModel.handleFeatureAction(feature.actionType)
                                }) {
                                    FeatureCard(feature: feature)
                                        .onTapGesture {
                                            selectedAction = feature.actionType
                                        }
                                }
                            }
                        }
                        .padding()
                    }
                    .frame(height: 500) // Prevents collapsing
                }
                .navigationDestination(item: $selectedAction) { action in
                    if action == .showCurrentLocation {
                        ShowMyLocationView()
                    } else if action == .startTracking {
                        StartTrackingView()
                    }
                }
            }
        }
    }

    /// Dynamically calculates the number of columns based on screen width
    private func adaptiveColumns(for width: CGFloat) -> [GridItem] {
        let minColumnWidth: CGFloat = 150  // Minimum width per item
        let maxColumns = Int(width / minColumnWidth)
        return Array(repeating: GridItem(.flexible()), count: max(maxColumns, 1))
    }
}

struct FeatureCard: View {
    let feature: FeatureModel

    var body: some View {
        VStack {
            Image(systemName: feature.icon)
                .font(.largeTitle)
                .foregroundColor(.blue)
                .padding()
            Text(feature.title)
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
        .frame(width: 150, height: 150)
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}

#Preview {
    DashboardView()
}
