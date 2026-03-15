//
//  ExpenseViewModel.swift
//  iFinanceHelper
//
//  Created by Vlad on 14/03/2026.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
@MainActor
class ExpenseViewModel {
    private var repository: ExpenseRepository

    init(repository: ExpenseRepository? = nil) {
        self.repository = repository ?? .shared
    }

    func deleteExpense(expense: Expense) {
        repository.context.delete(expense)
    }
}
