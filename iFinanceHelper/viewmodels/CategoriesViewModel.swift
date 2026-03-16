//
//  CategoriesViewModel.swift
//  iFinanceHelper
//
//  Created by Vlad on 16/03/2026.
//

import Foundation

class CategoriesViewModel{
    private var repository: ExpenseRepository

    init(repository: ExpenseRepository? = nil){
        self.repository = repository ?? ExpenseRepository.shared
    }

    final func saveTargetChanges(expenseTarget: ExpenseTypeTarget, targetAmount: Decimal) {
        guard targetAmount > 0 else { return }

        repository.editTargetForCategory(expenseTarget: expenseTarget, targetAmount: targetAmount)
    }
}
