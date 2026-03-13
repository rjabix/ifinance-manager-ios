//
//  Item.swift
//  iFinanceHelper
//
//  Created by Vlad on 13/03/2026.
//

import Foundation
import SwiftData

@Model
final class Expense {

    public var timestamp: Date

    public var amount: Decimal

    public var expenseType: ExpenseType

    public var note: String?

    init(amount: Decimal, expenseType: ExpenseType, timestamp: Date = .now, note: String? = nil) {
        precondition(amount >= 0, "Amount must be non-negative")
        self.timestamp = timestamp
        self.amount = amount
        self.expenseType = expenseType
        self.note = note
    }
}
