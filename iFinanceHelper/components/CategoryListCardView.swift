//
//  CategoryListCardView.swift
//  iFinanceHelper
//
//  Created by Vlad on 16/03/2026.
//

import SwiftUI

struct CategoryListCardView: View {
    var item: ExpenseTypeTotal

    var body: some View {
        let name = Constants.TypeToNameString[item.expenseType] ?? "Category"
        let iconName = Constants.TypeToSystemImageString[item.expenseType] ?? "questionmark.circle"
        let targetDecimal = max(item.targetAmount, 0)
        let spentDecimal = max(item.amount, 0)
        let target = NSDecimalNumber(decimal: targetDecimal).doubleValue
        let spent = NSDecimalNumber(decimal: spentDecimal).doubleValue
        let progress: Double = target > 0 ? max(spent / target, 0) : spent
        let currencyCode = Locale.current.currency?.identifier ?? "USD"
        let leftAmountDecimal = max(targetDecimal - spentDecimal, 0)

        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(.white.opacity(0.15))
                        )
                        .frame(width: 56, height: 56)

                    Image(systemName: iconName)
                        .font(.system(size: 26, weight: .semibold))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.headline)
                    Text("\(item.txnNumber) transactions")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 12)

                VStack(alignment: .trailing, spacing: 2) {
                    Text(spentDecimal.formatted(.currency(code: currencyCode)))
                        .font(.headline)
                    Text("of \(targetDecimal.formatted(.currency(code: currencyCode)))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding([.top, .horizontal])

            VStack(alignment: .leading, spacing: 6) {
                ProgressView(value: progress)
                    .tint(progress > 1 ? .red : .accentColor)
                    .progressViewStyle(.linear)

                HStack {
                    Text("\(Int((progress * 100).rounded()))% of budget")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(leftAmountDecimal.formatted(.currency(code: currencyCode))) left")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding([.bottom, .horizontal])
        }
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
        .padding()
    }
}

#Preview {
    CategoryListCardView(item: ExpenseTypeTotal(expenseType: .food, amount: 100, targetAmount: 0, txnNumber: 12))
}
