//
//  ContentView.swift
//  BBT Tracker
//
//  Created by Max Contreras on 2/19/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = TemperatureStore()
    @State private var showingCycleRecording = false
    
    var body: some View {
        TabView {
            RecordTemperatureView(store: store)
                .tabItem {
                    Label("Record", systemImage: "thermometer")
                }
          RecordFirstDayView(store: store)
            .tabItem {
              Label("First Day", systemImage: "calendar")
            }
            
            BTTChartView(store: store)
                .tabItem {
                    Label("Chart", systemImage: "chart.xyaxis.line")
                }
            
            BBTGuideView()
                .tabItem {
                    Label("Guide", systemImage: "book.fill")
                }
        }
        .overlay(alignment: .bottom) {
            if let days = store.daysSinceLastCycle() {
                Text("Day \(days) of cycle")
                    .font(.caption)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.bottom, 90)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingCycleRecording = true
                } label: {
                    Image(systemName: "drop.circle")
                }
            }
        }
        .sheet(isPresented: $showingCycleRecording) {
            RecordFirstDayView(store: store)
        }
    }
}

struct BBTGuideView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Important Guidelines") {
                    GuideRow(icon: "thermometer", 
                            title: "Use a Basal Thermometer",
                            description: "Basal thermometers show 2 decimal places (98.15°F vs 98.1°F)")
                    
                    GuideRow(icon: "bed.double.fill",
                            title: "Measure Before Getting Up",
                            description: "Take temperature immediately upon waking, before any activity")
                    
                    GuideRow(icon: "clock.fill",
                            title: "Consistent Timing",
                            description: "Take measurements at the same time each morning")
                    
                    GuideRow(icon: "calendar",
                            title: "Track Daily",
                            description: "Record temperature every day, starting from first day of cycle")
                }
                
                Section("When to Start") {
                    GuideRow(icon: "drop.fill",
                            title: "Begin on First Day",
                            description: "Start taking BBT on the first day of bleeding and continue every morning until your next cycle")
                }
                
                Section("Temperature Patterns") {
                    InfoRow(title: "Before Ovulation",
                           value: "96.0°F - 98.0°F")
                    InfoRow(title: "After Ovulation",
                           value: "97.0°F - 99.0°F")
                    InfoRow(title: "Typical Rise",
                           value: "≥ 0.4°F")
                }
                
                Section {
                    Text("Ovulation is indicated by an elevated temperature for at least 3 consecutive days. Most women ovulate around day 14 of their cycle.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("BBT Guide")
        }
    }
}

struct GuideRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .bold()
                .foregroundStyle(.blue)
        }
    }
}

#Preview {
    ContentView()
}
