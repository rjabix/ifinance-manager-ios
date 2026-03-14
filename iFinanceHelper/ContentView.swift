//
//  ContentView.swift
//  iFinanceHelper
//
//  Created by Vlad on 13/03/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            Tab(Constants.Home, systemImage: "house") {
                HomeView()
            }

            Tab(Constants.Expenses, systemImage: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90") {
                ExpensesView()
            }

            Tab(Constants.Add, systemImage: "plus.circle") {
                AddExpenseView()
            }

            Tab(Constants.Analytics, systemImage: "chart.bar.xaxis") {
                AnalyticsView()
            }

            Tab(Constants.Categories, systemImage: "rectangle.grid.3x2") {
                CategoriesView()
            }
        }
    }

}

#Preview {
    let repository = ExpenseRepository.shared
    ContentView()
        .modelContainer(repository.container)
}
