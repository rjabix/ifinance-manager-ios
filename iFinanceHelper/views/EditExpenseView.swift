//
//  EditExpenseView.swift
//  iFinanceHelper
//
//  Created by Vlad on 15/03/2026.
//

import SwiftUI
import SwiftData

struct EditExpenseView: View {
    @State var viewModel: EditExpenseViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showSuccessPopup: Bool = false

    init(item: Expense, repository: ExpenseRepository? = nil) {
        _viewModel = State(
            wrappedValue: EditExpenseViewModel(
                expense: item,
                repository: repository ?? ExpenseRepository.shared
            )
        )
    }

    var body: some View {
        ZStack {
            ScrollView {
                Text("Edit Expense")
                    .font(Font.largeTitle)

                Text("Track your spendings")

                AmountTextField(amount: $viewModel.expense.amount)
                    .padding()

                Label("Category", systemImage: "tag")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(Font.title3)
                    .padding([.top, .leading])

                CategoryGridView(
                    expenseType: Binding<ExpenseType?>(
                        get: { viewModel.expense.expenseType },
                        set: { newValue in
                            if let newValue {
                                viewModel.expense.expenseType = newValue
                            }
                        }
                    )
                )

                DatePickerCard(date: $viewModel.expense.timestamp)
                    .padding()

                NoteField(note: $viewModel.expense.note)

                Button("Edit this expense") {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    showSuccessPopup = true

                    withAnimation {
                        viewModel.saveExpenseChanges()
                    }

                    // Dismiss the sheet after a short delay to let the toast appear
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        dismiss()
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
                .buttonBorderShape(.capsule)
                .controlSize(.large)
                .disabled(viewModel.expense.amount <= 0.0)
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

    var successToast: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.blue)
            Text("Expense edited!")
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
    EditExpenseView(
        item: Expense(amount: 25.00, expenseType: .food),
        repository: repository
    )
    .modelContainer(repository.container)
}

