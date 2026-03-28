//
//  FilterExpensesPopoverView.swift
//  iFinanceHelper
//
//  Created by Vlad on 16/03/2026.
//

import SwiftUI

struct FilterExpensesPopoverView: View {

    @Binding var minAmount: Decimal?
    @Binding var maxAmount: Decimal?
    @Binding var sortOrderDescending: Bool
    @Binding var selectedCategory: ExpenseType?

    private var minAmountValueBinding: Binding<Decimal> {
        Binding(get: { minAmount ?? 0 }, set: { minAmount = $0 })
    }

    private var maxAmountValueBinding: Binding<Decimal> {
        Binding(get: { maxAmount ?? 0 }, set: { maxAmount = $0 })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            CategoryGridView(expenseType: $selectedCategory)

            Text("Amount range").font(.headline)

            TextField("Min", value: minAmountValueBinding, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)

            TextField("Max", value: maxAmountValueBinding, format: .number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)

            Picker("Order", selection: $sortOrderDescending) {
                Text("Newest first").tag(true)
                Text("Oldest first").tag(false)
            }
            .pickerStyle(.segmented)

            Button("Clear amount filters") {
                minAmount = nil
                maxAmount = nil
            }
        }
        .padding()
        .frame(width: 280)
        .presentationDetents([.medium])
    }
}

#Preview {
    PreviewWrapper()
}

private struct PreviewWrapper: View {
    @State private var minAmount: Decimal? = nil
    @State private var maxAmount: Decimal? = nil
    @State private var sortOrderDescending = false
    @State private var selectedCategory: ExpenseType? = nil

    var body: some View {
        FilterExpensesPopoverView(
            minAmount: $minAmount,
            maxAmount: $maxAmount,
            sortOrderDescending: $sortOrderDescending,
            selectedCategory: $selectedCategory
        )

        Text("\(String(describing: minAmount))")
        Text("\(String(describing: maxAmount))")
        Text("\(String(describing: sortOrderDescending))")
        Text("\(String(describing: selectedCategory?.rawValue))")
    }
}
