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
    @State private var isFilterMenuOpen: Bool = false
    @State private var minAmount: Decimal? = nil
    @State private var maxAmount: Decimal? = nil
    @State private var sortOrderDescending: Bool = true

    let repository: ExpenseRepository

    init(repository: ExpenseRepository? = nil) {
        self.repository = repository ?? ExpenseRepository.shared
        _viewModel = State(wrappedValue: ExpenseViewModel(repository: self.repository))
    }

    var body: some View {
        VStack {

            PeriodPickerView(dayPeriod: $dayPeriod)
                .padding()

            NavigationStack {
                ExpensesListContent(
                    dayPeriod: dayPeriod,
                    repository: repository,
                    onSelect: { expense in selectedExpense = expense },
                    onDelete: { expense in viewModel.deleteExpense(expense: expense) },
                    isFilterMenuOpen: $isFilterMenuOpen,
                    minAmount: $minAmount,
                    maxAmount: $maxAmount,
                    sortOrderDescending: $sortOrderDescending
                )
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

    private struct ExpensesListContent: View {
        let dayPeriod: Int
        let repository: ExpenseRepository
        let onSelect: (Expense) -> Void
        let onDelete: (Expense) -> Void

        @Binding var isFilterMenuOpen: Bool
        @Binding var minAmount: Decimal?
        @Binding var maxAmount: Decimal?
        @Binding var sortOrderDescending: Bool

        @Query private var items: [Expense]

        init(
            dayPeriod: Int,
            repository: ExpenseRepository,
            onSelect: @escaping (Expense) -> Void,
            onDelete: @escaping (Expense) -> Void,
            isFilterMenuOpen: Binding<Bool>,
            minAmount: Binding<Decimal?>,
            maxAmount: Binding<Decimal?>,
            sortOrderDescending: Binding<Bool>
        ) {
            self.dayPeriod = dayPeriod
            self.repository = repository
            self.onSelect = onSelect
            self.onDelete = onDelete
            self._isFilterMenuOpen = isFilterMenuOpen
            self._minAmount = minAmount
            self._maxAmount = maxAmount
            self._sortOrderDescending = sortOrderDescending

            _items = Query(
                filter: GetFilterPredicateBasedOnDaysAgo(daysAgo: dayPeriod),
                sort: \Expense.timestamp,
                order: sortOrderDescending.wrappedValue ? .reverse : .forward
            )
        }

        var body: some View {
            List {
                ForEach(
                    items.filter { exp in
                        let minOk = minAmount.map { exp.amount >= $0 } ?? true
                        let maxOk = maxAmount.map { exp.amount <= $0 } ?? true
                        return minOk && maxOk
                    }
                ) { item in
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isFilterMenuOpen.toggle()
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease")
                    }
                    .popover(isPresented: $isFilterMenuOpen) {
                        FilterExpensesPopoverView(minAmount: $minAmount, maxAmount: $maxAmount, sortOrderDescending: $sortOrderDescending)
                    }
                }

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
}

#Preview {
    let repository: ExpenseRepository = .preview
    return ExpensesView(repository: repository)
        .modelContainer(repository.container)
}
