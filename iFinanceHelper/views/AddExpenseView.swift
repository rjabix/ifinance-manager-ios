//
//  AddExpenseView.swift
//  iFinanceHelper
//
//  Created by Vlad on 13/03/2026.
//

import SwiftUI

struct AddExpenseView: View {
    @StateObject var viewModel: AddExpenseViewModel = AddExpenseViewModel()

    var body: some View {
        Text("Add Expense")
            .font(Font.largeTitle)

        Text("Track your spendings")

        AmountField
            .padding()

        Label("Category", systemImage: "tag")
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(Font.title3)
            .padding()

        CategoryGridView(viewModel: viewModel)
    }


    private var AmountField: some View {
        var body: some View {

            VStack {

                ZStack(alignment: .leading) {

                    // Card Background
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 140)

                    VStack(alignment: .leading, spacing: 10) {

                        // Icon + Label
                        HStack {
                            Image(systemName: "dollarsign")
                                .foregroundColor(.gray)

                            Text("Amount")
                                .foregroundColor(.gray)
                                .font(.title3)
                        }

                        // Amount Input
                        TextField("0.00", value: $viewModel.amount, format: .number)
                            .font(.system(size: 42, weight: .light))
                            .keyboardType(.decimalPad)
                    }
                    .padding(20)
                }
                .padding()
            }
        }

        return body
    }

    private struct Category: Identifiable {
        let id = UUID()
        let icon: String
        let name: String
        let expenseType: ExpenseType
    }

    struct CategoryGridView: View {

        var viewModel: AddExpenseViewModel

        init(viewModel: AddExpenseViewModel) {
            self.viewModel = viewModel
        }

        private let categories = [
            Category(icon: "burger", name: "Food", expenseType: .food),
            Category(icon: "🚗", name: "Transport", expenseType: .transport),
            Category(icon: "🛍️", name: "Shopping", expenseType: .shopping),
            Category(icon: "🎮", name: "Entertainment", expenseType: .entertainment),
            Category(icon: "📄", name: "Health", expenseType: .health),
            Category(icon: "💊", name: "Others", expenseType: .other)
        ]

        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        var body: some View {

            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(categories) { category in

                    Button() {
                        viewModel.expenseType = category.expenseType
                    } label: {
                        VStack(spacing: 10) {

                            Text(category.icon)
                                .font(.system(size: 40))

                            Text(category.name)
                                .font(.headline)
                        }
                        .frame(height: 110)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.gray.opacity(0.15))
                        )
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    AddExpenseView()
}
