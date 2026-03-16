//
//  ExpenseTypeTarget.swift
//  iFinanceHelper
//
//  Created by Vlad on 16/03/2026.
//

import Foundation
import SwiftData

@Model
final class ExpenseTypeTarget{

    var expenseType: ExpenseType
    var targetAmount: Decimal

    init(expenseType: ExpenseType, targetAmount: Decimal) {
        self.expenseType = expenseType
        self.targetAmount = targetAmount
    }
}
