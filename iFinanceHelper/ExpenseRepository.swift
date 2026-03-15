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

    // Create a specific instance for Previews
    static var preview: ExpenseRepository = {
        let repo = ExpenseRepository(isStoredInMemory: true)
        // Optionally seed with fake data here
        return repo
    }()

    let container: ModelContainer
    let context: ModelContext

    private init(isStoredInMemory: Bool = false) {
        do {
            let schema = Schema([Expense.self])
            let configuration = ModelConfiguration(isStoredInMemoryOnly: isStoredInMemory)

            container = try ModelContainer(for: schema, configurations: [configuration])
            context = container.mainContext
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    func addExpense(expense: Expense) {
        context.insert(expense)
    }

    func deleteExpense(expense: Expense) {
        context.delete(expense)
    }

    func saveChanges() throws {
        try context.save()
    }

    // You can also fetch manually here if needed outside of @Query
}
