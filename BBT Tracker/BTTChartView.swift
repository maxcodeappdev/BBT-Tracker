import SwiftUI
import Charts

struct BTTChartView: View {
    @ObservedObject var store: TemperatureStore
    
    private var sortedRecords: [TemperatureRecord] {
        store.records.sorted { $0.dateTime < $1.dateTime }
    }
    
    private let preOvulationRange = 96.0...98.0
    private let postOvulationRange = 97.0...99.0
    private let significantRise = 0.4
    
    private func formatTemperature(_ temp: Int) -> String {
        let whole = temp / 100
        let decimal = temp % 100
        return String(format: "%.2f°F", Double(whole) + Double(decimal)/100.0)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                if store.records.isEmpty {
                    ContentUnavailableView(
                        "No Temperature Data",
                        systemImage: "thermometer",
                        description: Text("Record your morning temperature to see patterns over time")
                    )
                } else {
                    ScrollViewReader { proxy in
                        VStack(alignment: .trailing) {
                            // Scroll to latest button
                            if sortedRecords.count > 7 {
                                Button {
                                    withAnimation {
                                        proxy.scrollTo(sortedRecords.last?.id, anchor: .trailing)
                                    }
                                } label: {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.blue)
                                        .padding(8)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                }
                                .padding(.horizontal)
                            }
                            
                            ScrollView(.horizontal, showsIndicators: true) {
                                VStack(alignment: .leading, spacing: 16) {
                                    TemperatureChartView(
                                        records: sortedRecords,
                                        preOvulationRange: preOvulationRange,
                                        postOvulationRange: postOvulationRange
                                    )
                                }
                            }
                        }
                        
                        // Legend
                        VStack(alignment: .leading, spacing: 8) {
                            LegendRow(color: .mint,
                                    title: "Pre-ovulation range",
                                    value: "96.0°F - 98.0°F")
                            LegendRow(color: .pink,
                                    title: "Post-ovulation range",
                                    value: "97.0°F - 99.0°F")
                            LegendRow(color: .green,
                                    title: "Your temperature",
                                    value: "")
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Temperature Chart")
        }
    }
}

struct TemperatureChartView: View {
    let records: [TemperatureRecord]
    let preOvulationRange: ClosedRange<Double>
    let postOvulationRange: ClosedRange<Double>
    
    var body: some View {
        Chart {
            // Pre-ovulation range area
            RectangleMark(
                xStart: .value("Start", records.first?.dateTime ?? Date()),
                xEnd: .value("End", records.last?.dateTime ?? Date()),
                yStart: .value("Low", preOvulationRange.lowerBound),
                yEnd: .value("High", preOvulationRange.upperBound)
            )
            .foregroundStyle(.mint.opacity(0.1))
            
            // Post-ovulation range area
            RectangleMark(
                xStart: .value("Start", records.first?.dateTime ?? Date()),
                xEnd: .value("End", records.last?.dateTime ?? Date()),
                yStart: .value("Low", postOvulationRange.lowerBound),
                yEnd: .value("High", postOvulationRange.upperBound)
            )
            .foregroundStyle(.pink.opacity(0.1))
            
            // Temperature points
            ForEach(records) { record in
                PointMark(
                    x: .value("Date", record.dateTime),
                    y: .value("Temperature", Double(record.temperature)/100.0)
                )
                .foregroundStyle(.green)
                .symbolSize(100)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        VStack(spacing: 4) {
                            Text(date, format: .dateTime.month(.abbreviated))
                                .font(.caption2)
                            Text(date, format: .dateTime.day())
                                .font(.caption)
                                .bold()
                        }
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let temp = value.as(Double.self) {
                        Text(String(format: "%.1f°F", temp))
                    }
                }
            }
        }
        .chartYScale(domain: 95...103)
        .frame(width: max(UIScreen.main.bounds.width - 40, CGFloat(records.count) * 60))
        .frame(height: 300)
        .padding(.vertical)
    }
}

#Preview {
    BTTChartView(store: {
        let store = TemperatureStore()
        let calendar = Calendar.current
        let today = Date()
        
        // Add sample data for the last 7 days
        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            let baseTemp = 97.0
            let variation = Double.random(in: -0.2...1.2)
            let temperature = Int((baseTemp + variation) * 100)
            
            let measurementDate = calendar.date(
                bySettingHour: 6,
                minute: Int.random(in: 0...30),
                second: 0,
                of: date
            ) ?? date
            
            let record = TemperatureRecord(
                dateTime: measurementDate,
                temperature: temperature
            )
            store.save(record)
        }
        
        return store
    }())
} 
