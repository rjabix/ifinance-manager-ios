import Foundation
import SwiftData
internal import Combine

@MainActor
@Observable
class AddExpenseViewModel {

    var amount: Decimal = 0.00
    var expenseType: ExpenseType? = nil
    var note: String?
    var date: Date = Date.now

    private var repository: ExpenseRepository

    init(repository: ExpenseRepository? = nil){
        self.repository = repository ?? ExpenseRepository.shared
    }

    final func saveExpense() {
        guard let expenseType = expenseType, amount > 0.00, date <= .now else { return }

        let expense = Expense(amount: amount, expenseType: expenseType, timestamp: date, note: note)

        repository.addExpense(expense: expense)

        self.resetFields()
    }

    private func resetFields() {
        amount = 0.00
        expenseType = nil
        note = nil
        date = .now
    }
}
