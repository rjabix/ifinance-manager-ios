//
//  AddExpenseView.swift
//  iFinanceHelper
//
//  Created by Vlad on 13/03/2026.
//

import SwiftUI
import SwiftData
import AVFoundation
import Fit

struct AddExpenseView: View {
    @State var viewModel: AddExpenseViewModel

    @State private var showSuccessPopup: Bool = false

    @Query var items: [Expense]

    init(repository: ExpenseRepository? = nil) {
        _viewModel = State(wrappedValue: AddExpenseViewModel(repository: repository ?? ExpenseRepository.shared))
        _items = Query(filter: GetFilterPredicateBasedOnDaysAgo(daysAgo: 7))
    }

    var body: some View {
        ZStack {
            ScrollView {
                Text("Add Expense")
                    .font(Font.largeTitle)

                Text("Track your spendings")

                AmountTextField(amount: $viewModel.amount)
                    .padding()

                Label("Category", systemImage: "tag")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(Font.title3)
                    .padding([.top, .leading])

                CategoryGridView(expenseType: $viewModel.expenseType)

                DatePickerCard(date: $viewModel.date)
                    .padding()

                NoteField(note: $viewModel.note)

                Fit {
                    ForEach(GetTags(items: items), id: \.self) { tag in
                        TagCardView(text: tag, selectedText: $viewModel.note ?? "")
                    }
                }

                Button("Add expense") {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    AudioServicesPlayAlertSound(SystemSoundID(1407))
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
                .buttonBorderShape(.capsule)
                .controlSize(.large)
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
