//
//  PeriodPickerView.swift
//  iFinanceHelper
//
//  Created by Vlad on 15/03/2026.
//

import SwiftUI

struct PeriodPickerView: View {
    @Binding var dayPeriod: Int

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        Picker("Period", selection: $dayPeriod) {
            Text("W")
                .font(.title)
                .tag(7)
            Text("M")
                .font(.title)
                .tag(30)
            Text("6M")
                .font(.title)
                .tag(180)
            Text("YTD")
                .font(.title)
                .tag(Date().dayOfYear)
            Text("Y")
                .font(.title)
                .tag(365)
        }
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
        .pickerStyle(.segmented)
    }
}

#Preview {
    @Previewable @State var dayPeriod: Int = 0
    VStack {
        PeriodPickerView(dayPeriod: $dayPeriod)
        Text("\(dayPeriod)")
    }
}
