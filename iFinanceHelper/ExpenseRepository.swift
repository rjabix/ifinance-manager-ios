//
//  DatabaseManager.swift
//  iFinanceHelper
//
//  Created by Vlad on 14/03/2026.
//

import Foundation
import SwiftData

@MainActor
class ExpenseRepository {
    static let shared = ExpenseRepository()

    let container: ModelContainer
    let context: ModelContext

    private init() {
        do {
            container = try ModelContainer(for: Expense.self)
            context = container.mainContext
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    func addExpense(expense: Expense) {
        context.insert(expense)
    }

    func deleteExpense(_ expense: Expense) {
        context.delete(expense)
    }

    // You can also fetch manually here if needed outside of @Query
}
