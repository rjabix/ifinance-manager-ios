//
//  AddExpenseView.swift
//  iFinanceHelper
//
//  Created by Vlad on 13/03/2026.
//

import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @State var viewModel: AddExpenseViewModel = AddExpenseViewModel()

    var body: some View {
        ScrollView {
            Text("Add Expense")
                .font(Font.largeTitle)

            Text("Track your spendings")

            AmountField
                .padding()

            Label("Category", systemImage: "tag")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(Font.title3)
                .padding([.top, .leading])

            CategoryGridView(viewModel: viewModel)

            DatePickerCard(date: $viewModel.date)
                .padding()

            NoteField(note: $viewModel.note)

            Button("Add expense", action: viewModel.saveExpense)
                .font(Font.title)
                .padding()
                .buttonStyle(.glassProminent)
        }
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

        @State var viewModel: AddExpenseViewModel

        private let categories = [
            Category(icon: "fork.knife", name: "Food", expenseType: .food),
            Category(icon: "car", name: "Transport", expenseType: .transport),
            Category(icon: "cart", name: "Shopping", expenseType: .shopping),
            Category(icon: "gamecontroller", name: "Entertainment", expenseType: .entertainment),
            Category(icon: "heart", name: "Health", expenseType: .health),
            Category(icon: "ellipsis", name: "Others", expenseType: .other)
        ]

        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        var body: some View {

            LazyVGrid(columns: columns, spacing: 20) {

                ForEach(categories) { category in

                    let isSelected = viewModel.expenseType == category.expenseType

                    Button {
                        viewModel.expenseType = category.expenseType
                    } label: {

                        VStack(spacing: 10) {

                            Image(systemName: category.icon)
                                .font(.system(size: 32))

                            Text(category.name)
                                .font(.headline)
                        }
                        .frame(height: 90)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.15))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                        )
                        .opacity(isSelected || viewModel.expenseType == nil ? 1 : 0.4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }

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

    struct NoteField: View {
        @Binding var note: String?

        var body: some View {

            HStack(spacing: 12) {

                Image(systemName: "note")
                    .font(.title2)
                    .padding([.leading])

                TextField("Note", text: $note ?? "")
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()

            }
            .frame(height: 80)
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [2]))
            )
            .padding([.horizontal])
        }
    }

}

#Preview {
    let repository = ExpenseRepository.shared

    AddExpenseView()
        .modelContainer(repository.container)
}
