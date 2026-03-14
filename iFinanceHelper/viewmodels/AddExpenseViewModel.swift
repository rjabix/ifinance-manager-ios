//
//  AddExpenseViewModel.swift
//  iFinanceHelper
//
//  Created by Vlad on 14/03/2026.
//

import Foundation
import Combine

class AddExpenseViewModel: ObservableObject {
    @Published var amount: Decimal = 0.00
    @Published var expenseType: ExpenseType = .other
    @Published var note: String?
    @Published var date: Date = Date.now

    private var cancellables = Set<AnyCancellable>()
}
