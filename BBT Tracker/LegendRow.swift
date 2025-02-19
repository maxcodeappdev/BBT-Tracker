//
//  LegendRow.swift
//  BBT Tracker
//
//  Created by Max Contreras on 2/19/25.
//

import SwiftUI

struct LegendRow: View {
    let color: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
                .font(.subheadline)
            if !value.isEmpty {
                Spacer()
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

//#Preview {
//    LegendRow()
//}
