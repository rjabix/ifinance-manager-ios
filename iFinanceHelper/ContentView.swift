//
//  ContentView.swift
//  iFinanceHelper
//
//  Created by Vlad on 13/03/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    let repository: ExpenseRepository

    init(repository: ExpenseRepository? = nil){
        self.repository = repository ?? .shared
    }

    var body: some View {
        TabView {
            Tab(Constants.Home, systemImage: "house") {
                HomeView()
            }

            Tab(Constants.Expenses, systemImage: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90") {
                ExpensesView(repository: repository)
            }

            Tab(Constants.Add, systemImage: "plus.circle") {
                AddExpenseView(repository: repository)
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
    let repository = ExpenseRepository.preview
    ContentView(repository: repository)
        .modelContainer(repository.container)
}
