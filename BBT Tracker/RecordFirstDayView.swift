//
//  RecordFirstDayView.swift
//  BBT Tracker
//
//  Created by Max Contreras on 2/19/25.
//

import SwiftUI

struct RecordFirstDayView: View {
    @ObservedObject var store: TemperatureStore
    @State private var selectedDate = Date()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select First Day")
                            .font(.headline)
                        
                        Text("Choose the first day of your menstrual cycle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        DatePicker("Start Date", 
                                 selection: $selectedDate,
                                 displayedComponents: [.date])
                            .datePickerStyle(.graphical)
                    }
                }
                
                Section {
                    Button("Record Cycle Start") {
                        // Create a cycle start record
                        let record = CycleRecord(
                            startDate: Calendar.current.startOfDay(for: selectedDate)
                        )
                        store.recordCycleStart(record)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                }
                
                Section {
                    Text("Recording your cycle's first day helps track ovulation patterns more accurately.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Record Cycle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Model for tracking cycle data
struct CycleRecord: Identifiable, Codable {
    let id: UUID
    let startDate: Date
    
    init(id: UUID = UUID(), startDate: Date) {
        self.id = id
        self.startDate = startDate
    }
}

#Preview {
    RecordFirstDayView(store: TemperatureStore())
}
