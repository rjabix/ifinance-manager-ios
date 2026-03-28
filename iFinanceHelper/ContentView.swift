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

    @State var searchText: String = ""

    init(repository: ExpenseRepository? = nil){
        self.repository = repository ?? .shared
    }

    var body: some View {
        TabView {

            Tab(Constants.Analytics, systemImage: "chart.bar.xaxis") {
                AnalyticsView()
            }

            Tab(Constants.Categories, systemImage: "tag") {
                CategoriesView()
            }

            Tab(Constants.Add, systemImage: "plus.circle") {
                AddExpenseView(repository: repository)
            }

            Tab(role: .search) {
                ExpensesView(repository: repository, searchText: searchText)
                    .searchable(text: $searchText)
            }
        }
    }

}

#Preview {
    let repository = ExpenseRepository.preview

    return ContentView(repository: repository)
        .modelContainer(repository.container)
}
