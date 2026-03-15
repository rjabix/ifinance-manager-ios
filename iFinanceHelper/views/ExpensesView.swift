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

    init(repository: ExpenseRepository? = nil) {
        _viewModel = State(wrappedValue: ExpenseViewModel(repository: repository ?? ExpenseRepository.shared))

        _items = Query(
            filter: GetFilterPredicateBasedOnDaysAgo(daysAgo: -7),
            sort: \.timestamp
        )
    }

    @Query private var items: [Expense]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        let timestampString = item.timestamp.formatted(Date.FormatStyle(date: .numeric, time: .standard))
                        let detailString = "Item at \(timestampString), amount: \(item.amount.formatted(.number.precision(.fractionLength(2))))"
                        Text(verbatim: detailString)
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                viewModel.deleteExpense(expense: items[index])
            }
        }
    }
}

#Preview {
    let repository = ExpenseRepository.preview
    ExpensesView(repository: repository)
        .modelContainer(repository.container)
}
