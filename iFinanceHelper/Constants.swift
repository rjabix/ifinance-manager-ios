//
//  Constants.swift
//  iFinanceHelper
//
//  Created by Vlad on 13/03/2026.
//

import Foundation
import SwiftUI

struct Constants {
    static let Home: String = "Home"
    static let Expenses: String = "Expenses"
    static let Add: String = "Add"
    static let Analytics: String = "Analytics"
    static let Categories: String = "Categories"

    static let TypeToSystemImageString: [ExpenseType: String] = [
        .food: "fork.knife",
        .transport: "car",
        .shopping: "cart",
        .entertainment: "gamecontroller",
        .health: "heart",
        .other: "ellipsis"
    ]

    static let TypeToNameString: [ExpenseType: String] = [
        .food: "Food",
        .transport: "Transport",
        .shopping: "Shopping",
        .entertainment: "Entertainment",
        .health: "Health",
        .other: "Other"
    ]

    static let TypeToColor: [ExpenseType: Color] = [
        .food: .green,
        .transport: .blue,
        .shopping: .yellow,
        .entertainment: .orange,
        .health: .purple,
        .other: .mint
    ]
}
