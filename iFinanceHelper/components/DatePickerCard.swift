//
//  DatePickerCard.swift
//  iFinanceHelper
//
//  Created by Vlad on 15/03/2026.
//

import SwiftUI



struct DatePickerCard: View {

    @Binding var date: Date
    @State private var showPicker = false

    var body: some View {

        Button {
            showPicker = true
        } label: {

            HStack(spacing: 12) {

                Image(systemName: "calendar")
                    .font(.title2)

                Text(dateText)
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()
            }
            .padding()
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.gray.opacity(0.15))
            )
        }
        .glassEffect(.regular, in: .rect(cornerRadius: 25))
        .buttonStyle(.plain)
        .sheet(isPresented: $showPicker) {

            VStack {

                DatePicker(
                    "Select date",
                    selection: $date,
                    in: ...Date.now,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()

                Button("Done") {
                    showPicker = false
                }
                .padding()
            }
            .presentationDetents([.medium])
        }
    }

    private var dateText: String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    DatePickerCardPreviewContainer()
}

private struct DatePickerCardPreviewContainer: View {
    @State private var date: Date = .now

    var body: some View {
        DatePickerCard(date: $date)
            .padding()
    }
}
