import SwiftUI

struct RecordTemperatureView: View {
    @ObservedObject var store: TemperatureStore
    @State private var selectedDate = Date()
    @State private var wholeNumber: Int = 97 // Default whole number
    @State private var decimal: Int = 0 // Default decimal places
    
    private var existingRecord: TemperatureRecord? {
        store.getRecord(for: selectedDate)
    }
    
    private var isEditing: Bool {
        existingRecord != nil
    }
    
    private var temperature: Int {
        // Convert the decimal input to match our storage format
        // For example: 97.40°F is stored as 9740
        wholeNumber * 100 + decimal
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Temperature") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your morning body temperature")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 0) {
                            Picker("Whole Number", selection: $wholeNumber) {
                                ForEach(95...103, id: \.self) { number in
                                    Text("\(number)").tag(number)
                                }
                            }
                            .labelsHidden()
                            
                            Text(".")
                                .font(.title2)
                            
                            Picker("Decimal", selection: $decimal) {
                                ForEach(0...99, id: \.self) { decimal in
                                    Text(String(format: "%02d", decimal)).tag(decimal)
                                }
                            }
                            .labelsHidden()
                            
                            Text("°F")
                                .font(.headline)
                        }
                    }
                }
                
                Section("Date & Time") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("When temperature was recorded")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        DatePicker("Date and Time", 
                                 selection: $selectedDate)
                            .labelsHidden()
                            .onChange(of: selectedDate) { oldDate, newDate in
                                if let record = store.getRecord(for: newDate) {
                                    wholeNumber = record.temperature / 100
                                    decimal = record.temperature % 100
                                } else {
                                    wholeNumber = 97
                                    decimal = 0
                                }
                            }
                    }
                }
                
                Section {
                    Button(isEditing ? "Update Temperature" : "Save Temperature") {
                        let record = TemperatureRecord(
                            dateTime: selectedDate,
                            temperature: temperature
                        )
                        store.save(record)
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                }
                
                if let ovulationDate = store.detectOvulation() {
                    Section {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ovulation Detected")
                                .font(.headline)
                            Text("Temperature rise indicates ovulation around \(ovulationDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Record Temperature")
        }
    }
}

#Preview {
    RecordTemperatureView(store: TemperatureStore())
} 