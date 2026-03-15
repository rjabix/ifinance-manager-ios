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
    let calendar = Calendar.current
    let nonNormalizedCalendarDaysAgo = calendar.date(byAdding: .day, value: daysAgo, to: .now) ?? .now
    let normalizedCalendarDaysAgo = calendar.startOfDay(for: nonNormalizedCalendarDaysAgo)

    return #Predicate<Expense> { expense in
        expense.timestamp >= normalizedCalendarDaysAgo
    }
}
