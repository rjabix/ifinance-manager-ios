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
    @State private var pageOffset: Int = 0 // 0 = current window, -1 = previous page
    @Query private var items: [Expense]

    private var daySpendings: [DaySpending] {
        let calendar = Calendar.current
        // Use the start of the day for the reference 'end' date shifted by pageOffset * dayPeriod
        let todayStart = calendar.startOfDay(for: Date())
        let shiftedEnd = calendar.date(byAdding: .day, value: pageOffset * dayPeriod, to: todayStart) ?? todayStart
        let windowStart = calendar.date(byAdding: .day, value: -(dayPeriod - 1), to: shiftedEnd) ?? shiftedEnd

        // Group items by their start of day
        let grouped = Dictionary(grouping: items) { expense in
            calendar.startOfDay(for: expense.timestamp)
        }

        // Build spendings only for days inside [windowStart, shiftedEnd]
        return grouped.compactMap { dayStart, dayItems in
            guard dayStart >= windowStart && dayStart <= shiftedEnd else { return nil }
            let diff = calendar.dateComponents([.day], from: dayStart, to: shiftedEnd).day ?? 0
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

                    Text("Total spendings in current time period by categories:")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TotalSpendingsByCategoriesBarChartView(
                        pageOffset: $pageOffset,
                        dayPeriod: dayPeriod,
                        spendingByDay: spendingByDay,
                        chartHeight: geo.size.height * 0.5,
                        endDate: {
                            let cal = Calendar.current
                            let today = cal.startOfDay(for: Date())
                            let candidate = cal.date(byAdding: .day, value: pageOffset * dayPeriod, to: today) ?? today
                            return min(candidate, today)
                        }()
                    )
                    
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .onChange(of: dayPeriod) { _, _ in
            pageOffset = 0
        }
    }

    private struct TotalSpendingsByCategoriesBarChartView : View {
        @Binding var pageOffset: Int
        var dayPeriod: Int
        var spendingByDay: [Int: DaySpending]
        let chartHeight: CGFloat
        let endDate: Date

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
                            x: .value("Day", Calendar.current.date(byAdding: .day, value: -day, to: endDate) ?? endDate, unit: .day),
                            y: .value("Spent", 0.0)
                        )
                    } else {
                        ForEach(dayCategories) { cs in
                            BarMark(
                                x: .value("Day", Calendar.current.date(byAdding: .day, value: -day, to: endDate) ?? endDate, unit: .day),
                                y: .value("Spent", cs.value)
                            )
                            .foregroundStyle(by: .value("Category", cs.categoryName))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: chartHeight)
            .gesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                    .onEnded { value in
                        let horizontal = value.translation.width
                        if horizontal < -40 { // swipe: go to newer page
                            withAnimation { pageOffset = min(pageOffset + 1, 0) }
                        } else if horizontal > 40 { // swipe - go to older page
                            withAnimation { pageOffset -= 1 }
                        }
                    }
            )
        }
    }
}

#Preview {
    let repository = ExpenseRepository.preview

    return AnalyticsView()
        .modelContainer(repository.container)
}
