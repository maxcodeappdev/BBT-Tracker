import Foundation

struct TemperatureRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let dateTime: Date
    let temperature: Int // Stored as integer (97.40°F -> 9740)
    
    init(id: UUID = UUID(), dateTime: Date, temperature: Int) {
        self.id = id
        self.dateTime = dateTime
        self.temperature = temperature
    }
    
    var formattedTemperature: String {
        let whole = temperature / 100
        let decimal = temperature % 100
        return String(format: "%.2f°F", Double(whole) + Double(decimal)/100.0)
    }
}

@MainActor
class TemperatureStore: ObservableObject {
    @Published private(set) var records: [TemperatureRecord] = []
    @Published private(set) var cycleRecords: [CycleRecord] = []
    
    private let saveKey = "SavedTemperatures"
    private let cycleRecordsKey = "SavedCycleRecords"
    
    init() {
        loadRecords()
        loadCycleRecords()
    }
    
    func save(_ record: TemperatureRecord) {
        if let index = records.firstIndex(where: { 
            Calendar.current.isDate($0.dateTime, inSameDayAs: record.dateTime) 
        }) {
            // Update existing record
            records[index] = record
        } else {
            // Add new record
            records.append(record)
        }
        saveRecords()
    }
    
    func getRecord(for date: Date) -> TemperatureRecord? {
        records.first(where: { 
            Calendar.current.isDate($0.dateTime, inSameDayAs: date)
        })
    }
    
    func delete(_ record: TemperatureRecord) {
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records.remove(at: index)
            saveRecords()
        }
    }
    
    // MARK: - Persistence
    
    private func saveRecords() {
        do {
            let data = try JSONEncoder().encode(records)
            UserDefaults.standard.set(data, forKey: saveKey)
        } catch {
            print("Failed to save temperature records: \(error.localizedDescription)")
        }
    }
    
    private func loadRecords() {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else { return }
        
        do {
            records = try JSONDecoder().decode([TemperatureRecord].self, from: data)
        } catch {
            print("Failed to load temperature records: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Analysis
    
    func detectOvulation() -> Date? {
        let sortedRecords = records.sorted { $0.dateTime < $1.dateTime }
        guard sortedRecords.count >= 3 else { return nil }
        
        // Look for 3 consecutive days of elevated temperature (≥0.4°F rise)
        for i in 0...(sortedRecords.count - 3) {
            let temp1 = Double(sortedRecords[i].temperature) / 100.0
            let temp2 = Double(sortedRecords[i + 1].temperature) / 100.0
            let temp3 = Double(sortedRecords[i + 2].temperature) / 100.0
            
            // Check if all three temperatures are elevated
            if temp2 >= (temp1 + 0.4) && temp3 >= (temp1 + 0.4) {
                // Return the date of the first elevated temperature
                return sortedRecords[i + 1].dateTime
            }
        }
        
        return nil
    }
    
    // Cycle tracking methods
    func recordCycleStart(_ record: CycleRecord) {
        cycleRecords.append(record)
        saveCycleRecords()
    }
    
    private func saveCycleRecords() {
        do {
            let data = try JSONEncoder().encode(cycleRecords)
            UserDefaults.standard.set(data, forKey: cycleRecordsKey)
        } catch {
            print("Failed to save cycle records: \(error.localizedDescription)")
        }
    }
    
    private func loadCycleRecords() {
        guard let data = UserDefaults.standard.data(forKey: cycleRecordsKey) else { return }
        
        do {
            cycleRecords = try JSONDecoder().decode([CycleRecord].self, from: data)
        } catch {
            print("Failed to load cycle records: \(error.localizedDescription)")
        }
    }
    
    func daysSinceLastCycle() -> Int? {
        guard let lastCycle = cycleRecords.sorted(by: { $0.startDate > $1.startDate }).first else {
            return nil
        }
        
        return Calendar.current.dateComponents([.day], 
                                            from: lastCycle.startDate, 
                                            to: Date()).day
    }
} 