//
//  AnalyticsView.swift
//  iFinanceHelper
//
//  Created by Vlad on 13/03/2026.
//

import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {

    private struct DaySpending: Identifiable {
        var id = UUID()
        var totalAmount: Double
        var dayTillStartOfChart: Int
        var spendingPerCategory: [ExpenseType: Double]

        init(itemsThisDay: [Expense], dayTillStartOfChart: Int) {
            self.dayTillStartOfChart = dayTillStartOfChart
            self.totalAmount = itemsThisDay.reduce(0.0) { $0 + Double(truncating: $1.amount as NSNumber) }
            self.spendingPerCategory = itemsThisDay.reduce(into: [ExpenseType: Double]()) { result, item in
                result[item.expenseType, default: 0.0] += Double(truncating: item.amount as NSNumber)
            }
        }
    }

    @State private var dayPeriod: Int = 7
    @Query private var items: [Expense]

    private var daySpendings: [DaySpending] {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())

        let grouped = Dictionary(grouping: items) { expense in
            calendar.startOfDay(for: expense.timestamp)
        }

        return grouped.compactMap { dayStart, dayItems in
            let diff = calendar.dateComponents([.day], from: dayStart, to: todayStart).day ?? 0
            guard diff >= 0 && diff < dayPeriod else { return nil }
            return DaySpending(itemsThisDay: dayItems, dayTillStartOfChart: diff)
        }
        .sorted { $0.dayTillStartOfChart < $1.dayTillStartOfChart }
    }

    private var spendingByDay: [Int: DaySpending] {
        Dictionary(uniqueKeysWithValues: daySpendings.map { ($0.dayTillStartOfChart, $0) })
    }

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack {
                    PeriodPickerView(dayPeriod: $dayPeriod)
                        .padding([.top, .bottom])
                    
#if DEBUG
                    Text("Days loaded: \(daySpendings.count)")
#endif
                    
                    FirstBarChartView(dayPeriod: dayPeriod, spendingByDay: spendingByDay, chartHeight: geo.size.height * 0.5)
                    
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }

    private struct FirstBarChartView : View {
        var dayPeriod: Int
        var spendingByDay: [Int: DaySpending]
        let chartHeight: CGFloat

        private struct CategorySpending: Identifiable {
            let id = UUID()
            let categoryName: String
            let value: Double
        }

        private func categories(for day: Int) -> [CategorySpending] {
            guard let spending = spendingByDay[day] else { return [] }
            return spending.spendingPerCategory.map { key, value in
                CategorySpending(categoryName: String(describing: key), value: value)
            }
        }

        var body: some View {
            Chart {
                ForEach(0..<dayPeriod, id: \.self) { day in
                    let dayCategories = categories(for: day)
                    if dayCategories.isEmpty {
                        BarMark(
                            x: .value("Day", GetDateByDaysAgo(daysAgo: day), unit: .day),
                            y: .value("Spent", 0.0)
                        )
                    } else {
                        ForEach(dayCategories) { cs in
                            BarMark(
                                x: .value("Day", GetDateByDaysAgo(daysAgo: day), unit: .day),
                                y: .value("Spent", cs.value)
                            )
                            .foregroundStyle(by: .value("Category", cs.categoryName))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: chartHeight)
        }
    }
}

#Preview {
    let repository = ExpenseRepository.preview

    return AnalyticsView()
        .modelContainer(repository.container)
}
