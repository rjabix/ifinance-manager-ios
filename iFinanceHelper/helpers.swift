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

func GetTags(items: [Expense]) -> [String] {
    // Build frequency of words across notes, counting each word at most once per item
    var frequency: [String: Int] = [:]

    for expense in items {
        // Assuming Expense has an optional `note` property of type String?
        let raw = (expense.note ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { continue }

        // Lowercase and remove punctuation/symbols
        let lowered = raw.lowercased()
        // Keep alphanumerics and apostrophes as scalars, replace others with space
        let apostrophe = Unicode.Scalar(39) // '\''
        let cleanedScalarArray: [Unicode.Scalar] = lowered.unicodeScalars.map { scalar in
            if CharacterSet.alphanumerics.contains(scalar) || scalar == apostrophe {
                return scalar
            } else {
                return Unicode.Scalar(32) // space
            }
        }
        let cleaned = String(String.UnicodeScalarView(cleanedScalarArray))
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Tokenize and filter out tokens containing digits and 1-letter tokens
        let digitSet = CharacterSet.decimalDigits
        let tokens = cleaned.split(separator: " ")
            .map { String($0) }
            .filter { $0.count > 1 && $0.rangeOfCharacter(from: digitSet) == nil }

        // Count each word at most once per item
        var uniqueInItem = Set<String>()
        for word in tokens {
            if uniqueInItem.insert(word).inserted {
                frequency[word, default: 0] += 1
            }
        }
    }

    // Sort by frequency desc, then alphabetically asc for stable order, and take top 10
    let sorted = frequency.sorted { lhs, rhs in
        if lhs.value != rhs.value { return lhs.value > rhs.value }
        return lhs.key < rhs.key
    }

    return Array(sorted.prefix(10).map { $0.key })
}

extension Date {
    var dayOfYear: Int {
        return Calendar.current.ordinality(of: .day, in: .year, for: self)!
    }
}
