//
//  iFinanceHelperApp.swift
//  iFinanceHelper
//
//  Created by Vlad on 13/03/2026.
//

import SwiftUI
import SwiftData

@main
struct iFinanceHelperApp: App {
    let repository = ExpenseRepository.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(repository.container)
    }
}
