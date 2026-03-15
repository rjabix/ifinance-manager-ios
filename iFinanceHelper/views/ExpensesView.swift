//
//  ExpensesView.swift
//  iFinanceHelper
//
//  Created by Vlad on 13/03/2026.
//

import SwiftUI
import SwiftData

struct ExpensesView: View {
    @State var viewModel: ExpenseViewModel
    @State private var dayPeriod: Int = 7
    @State private var selectedExpense: Expense?

    let repository: ExpenseRepository

    init(repository: ExpenseRepository? = nil) {
        self.repository = repository ?? ExpenseRepository.shared
        _viewModel = State(wrappedValue: ExpenseViewModel(repository: self.repository))
    }

    var body: some View {
        VStack {
            Text("All expenses")
                .font(.largeTitle)
                .padding()

            PeriodPickerView(dayPeriod: $dayPeriod)
                .padding()

            NavigationSplitView {
                ExpensesListContent(
                    dayPeriod: dayPeriod,
                    repository: repository,
                    onSelect: { expense in
                        selectedExpense = expense
                    },
                    onDelete: { expense in
                        viewModel.deleteExpense(expense: expense)
                    }
                )
            } detail: {
                Text("Select an item")
            }
        }
        .fullScreenCover(item: $selectedExpense) { expense in
            NavigationStack {
                EditExpenseView(item: expense, repository: repository)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                selectedExpense = nil
                            } label: {
                                Label("Back", systemImage: "chevron.backward")
                            }
                        }
                    }
            }
        }
    }
}

private struct ExpensesListContent: View {
    let dayPeriod: Int
    let repository: ExpenseRepository
    let onSelect: (Expense) -> Void
    let onDelete: (Expense) -> Void

    @Query private var items: [Expense]

    init(
        dayPeriod: Int,
        repository: ExpenseRepository,
        onSelect: @escaping (Expense) -> Void,
        onDelete: @escaping (Expense) -> Void
    ) {
        self.dayPeriod = dayPeriod
        self.repository = repository
        self.onSelect = onSelect
        self.onDelete = onDelete
        _items = Query(
            filter: GetFilterPredicateBasedOnDaysAgo(daysAgo: dayPeriod),
            sort: \Expense.timestamp,
            order: .reverse
        )
    }

    var body: some View {
        List {
            ForEach(items) { item in
                Button {
                    onSelect(item)
                } label: {
                    ExpenseDetailsListCardView(item: item)
                }
                .buttonStyle(.plain)
            }
            .onDelete(perform: deleteItems)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            onDelete(items[index])
        }
    }
}

#Preview {
    let repository: ExpenseRepository = .preview
    repository.addExpense(expense: Expense(amount: 25.00, expenseType: .food))
    repository.addExpense(expense: Expense(amount: 20.00, expenseType: .entertainment, note: "Movies"))
    repository.addExpense(expense: Expense(amount: 125.00, expenseType: .transport, timestamp: GetDateByDaysAgo(daysAgo: 20), note: "less than a month ago"))
    repository.addExpense(expense: Expense(amount: 125.00, expenseType: .transport, timestamp: GetDateByDaysAgo(daysAgo: 350), note: "less than a year ago"))
    repository.addExpense(expense: Expense(amount: 125.00, expenseType: .transport, timestamp: Date(timeIntervalSince1970: TimeInterval(20)), note: "more than a year ago"))
    return ExpensesView(repository: repository)
        .modelContainer(repository.container)
}
