//
//  helpers.swift
//  iFinanceHelper
//
//  Created by Vlad on 14/03/2026.
//

import Foundation
import SwiftUI

    // Source - https://stackoverflow.com/a/61002589
    // Posted by Jonathan.
    // Retrieved 2026-03-14, License - CC BY-SA 4.0

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
        Binding(
            get: { lhs.wrappedValue ?? rhs },
            set: { lhs.wrappedValue = $0 }
        )
}

func GetFilterPredicateBasedOnDaysAgo(daysAgo: Int) -> Predicate<Expense> {
    let normalizedCalendarDaysAgo = GetDateByDaysAgo(daysAgo: daysAgo)
    return #Predicate<Expense> { expense in
        expense.timestamp >= normalizedCalendarDaysAgo
    }
}

func GetDateByDaysAgo(daysAgo: Int) -> Date {
    let calendar = Calendar.current
    let nonNormalizedCalendarDaysAgo = calendar.date(byAdding: .day, value: -1 * daysAgo, to: .now) ?? .now
    let normalizedCalendarDaysAgo = calendar.startOfDay(for: nonNormalizedCalendarDaysAgo)

    return normalizedCalendarDaysAgo
}

func GetExpensesSum(items: [Expense]) -> Decimal {
    return items.reduce(.zero) { $0 + $1.amount }
}

func GetExpenseTargetsSum(items: [ExpenseTypeTarget]) -> Decimal {
    return items.reduce(.zero) { $0 + $1.targetAmount }
}
