//
//  AddExpenseView.swift
//  iFinanceHelper
//
//  Created by Vlad on 13/03/2026.
//

import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @State var viewModel: AddExpenseViewModel

    @State private var showSuccessPopup: Bool = false

    init(repository: ExpenseRepository? = nil) {
        _viewModel = State(wrappedValue: AddExpenseViewModel(repository: repository ?? ExpenseRepository.shared))
    }

    var body: some View {
        ZStack {
            ScrollView {
                Text("Add Expense")
                    .font(Font.largeTitle)

                Text("Track your spendings")

                AmountField(amount: $viewModel.amount)
                    .padding()

                Label("Category", systemImage: "tag")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(Font.title3)
                    .padding([.top, .leading])

                CategoryGridView(expenseType: $viewModel.expenseType)

                DatePickerCard(date: $viewModel.date)
                    .padding()

                NoteField(note: $viewModel.note)

                Button("Add expense") {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    showSuccessPopup = true

                    withAnimation {
                        viewModel.saveExpense()
                    }

                    // Automatically hide the popup after 1.5 sec
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            showSuccessPopup = false
                        }
                    }
                }
                .font(.title)
                .padding()
                .buttonStyle(.glassProminent)
                .disabled(viewModel.amount <= 0 || viewModel.expenseType == nil)
            }

            // 2. The Popup UI
            if showSuccessPopup {
                VStack {
                    successToast
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .padding(.bottom, 50)
                .zIndex(1) // Ensure it stays on top
            }
        }
    }


    struct AmountField: View {
        @Binding var amount: Decimal

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
                        TextField("0.00", value: $amount, format: .number)
                            .font(.system(size: 42, weight: .light))
                            .keyboardType(.decimalPad)
                    }
                    .padding(20)
                }
                .padding()
            }
        }
    }

    struct CategoryGridView: View {

        @Binding var expenseType: ExpenseType?

        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        var body: some View {

            LazyVGrid(columns: columns, spacing: 20) {

                ForEach(ExpenseType.allCases, id: \.self) { type in

                    let isSelected = $expenseType.wrappedValue == type

                    Button {
                        $expenseType.wrappedValue = type
                    } label: {

                        VStack(spacing: 10) {

                            Image(systemName: Constants.TypeToSystemImageString[type]!)
                                .font(.system(size: 32))

                            Text(Constants.TypeToNameString[type]!)
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
                        .opacity(isSelected || $expenseType.wrappedValue == nil ? 1 : 0.4)
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

    var successToast: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.blue)
            Text("Expense Added!")
                .font(.headline)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
        .cornerRadius(25)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .glassEffect()
    }
}

#Preview {
    let repository = ExpenseRepository.preview

    AddExpenseView(repository: repository)
        .modelContainer(repository.container)
}
