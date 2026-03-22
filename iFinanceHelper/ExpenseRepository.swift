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
        let repository = ExpenseRepository(isStoredInMemory: true)

        repository.addExpense(expense: Expense(amount: 25.00, expenseType: .food))
        repository.addExpense(expense: Expense(amount: 125.00, expenseType: .entertainment, note: "Movies"))
        repository.addExpense(expense: Expense(amount: 125.00, expenseType: .transport, timestamp: GetDateByDaysAgo(daysAgo: 1), note: "yesterday"))
        repository.addExpense(expense: Expense(amount: 130.00, expenseType: .health, timestamp: GetDateByDaysAgo(daysAgo: 1), note: "yesterdayhealth"))
        repository.addExpense(expense: Expense(amount: 125.00, expenseType: .transport, timestamp: GetDateByDaysAgo(daysAgo: 350), note: "less than a year ago"))
        repository.addExpense(expense: Expense(amount: 125.00, expenseType: .transport, timestamp: GetDateByDaysAgo(daysAgo: 14), note: "less than a month ago"))
        repository.addExpense(expense: Expense(amount: 125.00, expenseType: .transport, timestamp: Date(timeIntervalSince1970: TimeInterval(20)), note: "more than a year ago"))
        
        return repository
    }()

    let container: ModelContainer
    let context: ModelContext

    private init(isStoredInMemory: Bool = false) {
        do {
            let schema = Schema([Expense.self, ExpenseTypeTarget.self])
            let configuration = ModelConfiguration(isStoredInMemoryOnly: isStoredInMemory)

            container = try ModelContainer(for: schema, configurations: [configuration])
            context = container.mainContext

            // Ensure we have exactly 6 category targets seeded
            seedDefaultExpenseTypeTargetsIfNeeded()
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

    func editTargetForCategory(expenseTarget: ExpenseTypeTarget, targetAmount: Decimal) {
        let clamped = max(targetAmount, 0)
        expenseTarget.targetAmount = clamped
        try? context.save()
    }

    // MARK: - ExpenseTypeTarget management (limited to exactly 6)

    private func seedDefaultExpenseTypeTargetsIfNeeded() {
        do {
            let descriptor = FetchDescriptor<ExpenseTypeTarget>()
            let existing = try context.fetch(descriptor)
            if existing.isEmpty {
                // Seed exactly 6 targets
                for type in ExpenseType.allCases {
                    let target = ExpenseTypeTarget(expenseType: type, targetAmount: 0)
                    context.insert(target)
                }
                try context.save()
            } else if existing.count != ExpenseType.allCases.count {
                // If data is in an unexpected state, normalize to exactly 6
                // Strategy: remove extras and add missing
                let typesSet = Set(existing.map { $0.expenseType })

                // Add missing
                for type in ExpenseType.allCases where !typesSet.contains(type) {
                    let target = ExpenseTypeTarget(expenseType: type, targetAmount: 0)
                    context.insert(target)
                }

                // Delete extras
                let allowed = Set(ExpenseType.allCases)
                for target in existing where !allowed.contains(target.expenseType) {
                    context.delete(target)
                }
                try? context.save()
            }
        } catch {
            // If fetch fails, attempt a minimal seed
            for type in ExpenseType.allCases {
                let target = ExpenseTypeTarget(expenseType: type, targetAmount: 100)
                context.insert(target)
            }
            try? context.save()
        }
    }

    func fetchAllTargets() -> [ExpenseTypeTarget] {
        do {
            return try context.fetch(FetchDescriptor<ExpenseTypeTarget>())
        } catch {
            return []
        }
    }
}
