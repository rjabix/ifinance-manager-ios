//
//  ExpensesView.swift
//  iFinanceHelper
//
//  Created by Vlad on 13/03/2026.
//

import SwiftUI
import SwiftData

struct ExpensesView: View {
    @Environment(\.modelContext) private var modelContext
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

    private func addItem() {
        withAnimation {
            let newItem = Expense(amount: 10.0, expenseType: .food)
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ExpensesView()
        .modelContainer(for: Expense.self, inMemory: true)
}
