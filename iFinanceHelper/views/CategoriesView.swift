//
//  CategoriesView.swift
//  iFinanceHelper
//
//  Created by Vlad on 13/03/2026.
//

import SwiftUI
import SwiftData

struct CategoriesView: View {

    @State private var viewModel: CategoriesViewModel

    @State private var showEditPopup: Bool = false
    @State private var categoryToEdit: ExpenseType = .food
    @State private var categoryAmountToEdit: Decimal = .zero

    @Query var targets: [ExpenseTypeTarget]
    @Query var items: [Expense]

    init(repository: ExpenseRepository? = nil) {
        let repo = repository ?? ExpenseRepository.shared
        _viewModel = State(initialValue: CategoriesViewModel(repository: repo))
        _targets = Query()
        _items = Query(filter: GetFilterPredicateBasedOnDaysAgo(daysAgo: 30))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Categories this month")
                            .font(.largeTitle)

                        Text("Manage your budgets")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                OverviewView(items: items, targets: targets)
                .padding()
                .glassEffect(.regular, in: .rect(cornerRadius: 25))
                .padding()

                ForEach(ExpenseType.allCases, id: \.self) { type in
                    CategoryCardView(
                        expenseType: type,
                        targets: targets,
                        items: items
                    )
                }
            }
            .toolbar {
                Button {
                    showEditPopup = true
                } label: {
                    HStack {
                        Label("Edit", systemImage: "pencil")
                    }
                }
                .buttonStyle(.glassProminent)
                .popover(isPresented: $showEditPopup) {
                    VStack{
                        Text("Edit category targets")
                            .font(.headline)

                        Spacer()

                        Picker("Category", selection: $categoryToEdit) {
                            ForEach(ExpenseType.allCases, id: \.self) { type in
                                Text(String(describing: type).capitalized).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding()

                        TextField("Amount", value: $categoryAmountToEdit, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                            .padding()

                        Button("Done") {
                            viewModel.saveTargetChanges(expenseTarget: targets.first(where: {$0.expenseType == categoryToEdit})!, targetAmount: categoryAmountToEdit)
                        }
                        .padding()
                    }
                    .padding()
                    .frame(width: 280)
                    .presentationDetents([.medium])
                }
            }
            .padding()
        }
        .onAppear {
            if let firstFood = items.first(where: { $0.expenseType == .food }) {
                categoryAmountToEdit = firstFood.amount
            }
        }
    }

    struct OverviewView: View {
        var items: [Expense]
        var targets: [ExpenseTypeTarget]

        private var totalSpent: Decimal {
            GetExpensesSum(items: items)
        }

        private var totalTarget: Decimal {
            GetExpenseTargetsSum(items: targets)
        }

        private var remainingPercent: Double {
            guard totalTarget != .zero else { return 0 }
            let spent = NSDecimalNumber(decimal: totalSpent).doubleValue
            let target = NSDecimalNumber(decimal: totalTarget).doubleValue
            return 100 - (spent / target) * 100
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Overview")
                    .font(.headline)
                HStack {
                    Text("Spent: \(totalSpent.formatted())")
                    Spacer()
                    Text("Target: \(totalTarget.formatted())")
                    Spacer()
                    Text("\(remainingPercent >= 0 ? "Remaining" : "Overspent:"): \(remainingPercent.formatted(.number.precision(.fractionLength(0))))\u{25}")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    struct CategoryCardView: View {
        let expenseType: ExpenseType
        let targets: [ExpenseTypeTarget]
        let items: [Expense]

        private var target: ExpenseTypeTarget? {
            targets.first(where: { $0.expenseType == expenseType })
        }

        private var filteredItems: [Expense] {
            items.filter { $0.expenseType == expenseType }
        }

        var body: some View {
            CategoryListCardView(
                item: ExpenseTypeTotal(
                    expenseType: expenseType,
                    amount: GetExpensesSum(items: filteredItems),
                    targetAmount: target!.targetAmount,
                    txnNumber: filteredItems.count
                )
            )
        }
    }
}

#Preview {
    let repository = ExpenseRepository.preview

    return CategoriesView(repository: repository)
        .modelContainer(repository.container)
}
