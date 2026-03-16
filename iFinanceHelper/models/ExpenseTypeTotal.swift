//
//  ExpenseTypeTotal.swift
//  iFinanceHelper
//
//  Created by Vlad on 16/03/2026.
//

import Foundation

final class ExpenseTypeTotal {
    var expenseType: ExpenseType
    var amount: Decimal
    var targetAmount: Decimal
    var txnNumber: Int

    init(expenseType: ExpenseType, amount: Decimal, targetAmount: Decimal, txnNumber: Int) {
        self.expenseType = expenseType
        self.amount = amount
        self.targetAmount = targetAmount
        self.txnNumber = txnNumber
    }
}
