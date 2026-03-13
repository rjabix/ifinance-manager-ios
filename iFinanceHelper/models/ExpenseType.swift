//
//  ExpenseType.swift
//  iFinanceHelper
//
//  Created by Vlad on 13/03/2026.
//

import Foundation

enum ExpenseType: String, Codable, CaseIterable {
    case food
    case transport
    case shopping
    case entertainment
    case health
    case other
}
