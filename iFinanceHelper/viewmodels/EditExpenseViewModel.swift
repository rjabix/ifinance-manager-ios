//
//  EditExpenseViewModel.swift
//  iFinanceHelper
//
//  Created by Vlad on 15/03/2026.
//

import Foundation

@MainActor
@Observable
class EditExpenseViewModel {

    var expense: Expense

    private var repository: ExpenseRepository

    init(expense: Expense, repository: ExpenseRepository? = nil){
        self.expense = expense
        self.repository = repository ?? ExpenseRepository.shared
    }

    final func saveExpenseChanges() {
        guard expense.amount > 0.00, expense.timestamp <= .now else { return }

        try? repository.saveChanges()
    }
}
