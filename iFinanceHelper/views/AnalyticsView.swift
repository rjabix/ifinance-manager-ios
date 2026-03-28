//
//  AnalyticsView.swift
//  iFinanceHelper
//
//  Created by Vlad on 13/03/2026.
//

import SwiftUI
import SwiftData
import Charts
import Foundation

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

    // Consistent colors for categories across charts
    private static let categoryColors: [ExpenseType: Color] = {
        var map: [ExpenseType: Color] = [:]
        let base: [Color] = [
            .blue, .green, .orange, .pink, .purple, .teal, .red, .indigo, .yellow, .mint, .cyan, .brown
        ]
        for (idx, type) in ExpenseType.allCases.enumerated() {
            map[type] = base[idx % base.count]
        }
        return map
    }()

    private func color(for type: ExpenseType) -> Color {
        AnalyticsView.categoryColors[type] ?? .accentColor
    }

    private static func colorFor(_ type: ExpenseType) -> Color {
        categoryColors[type] ?? .accentColor
    }

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

                    Text("Total spendings in current time period by categories:")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TotalTimelineSpendingsByCategoriesBarChartView(
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

                    Spacer()

                    Divider()
                        .padding([.top])

                    LegendView()

                    Divider()

                    Spacer()

                    TotalCategorySpendingDonutChartView(
                        pageOffset: $pageOffset,
                        dayPeriod: dayPeriod,
                        items: items,
                        chartHeight: geo.size.height * 0.5)

                    Divider()

                    RecordsView(items: items, dayPeriod: dayPeriod, pageOffset: pageOffset)

                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .onChange(of: dayPeriod) { _, _ in
            withAnimation {
                pageOffset = 0
            }
        }
    }

    private struct LegendView: View {
        private let columns = [
            GridItem(.flexible(), alignment: .leading),
            GridItem(.flexible(), alignment: .leading),
            GridItem(.flexible(), alignment: .leading)
        ]

        var body: some View {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(ExpenseType.allCases, id: \.self) { type in
                    HStack(alignment: .center, spacing: 8) {
                        Circle()
                            .fill(AnalyticsView.colorFor(type))
                            .frame(width: 18, height: 18)

                        Text(type.rawValue.capitalized)
                            .font(.caption)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private struct TotalTimelineSpendingsByCategoriesBarChartView : View {
        @Binding var pageOffset: Int
        var dayPeriod: Int
        var spendingByDay: [Int: DaySpending]
        let chartHeight: CGFloat
        let endDate: Date

        @State var rawSelectedDate: Date?

        private struct CategorySpending: Identifiable {
            let id = UUID()
            let type: ExpenseType
            let categoryName: String
            let value: Double
        }

        private func categories(for day: Int) -> [CategorySpending] {
            guard let spending = spendingByDay[day] else { return [] }
            return spending.spendingPerCategory.map { key, value in
                CategorySpending(type: key, categoryName: String(describing: key), value: value)
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
                            .foregroundStyle(AnalyticsView.colorFor(cs.type))
                        }
                    }
                }

                if let rawSelectedDate {
                    RuleMark(x: .value("Selected", rawSelectedDate, unit: .day))
                        .foregroundStyle(Color.gray.opacity(0.3))
                        .zIndex(-1)
                        .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            LineMarkPopoverView(rawSelectedDate: rawSelectedDate, dayCategories: categories(for: dayIndex(from: rawSelectedDate)))
                        }
                }
            }
            .chartXSelection(value: $rawSelectedDate)
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

        private struct LineMarkPopoverView: View {
            var rawSelectedDate: Date
            var dayCategories: [CategorySpending]

            var body: some View {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none

                return VStack {
                    Text(dateFormatter.string(from: rawSelectedDate))
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)

                    HStack {
                        ForEach(dayCategories.sorted {$0.value > $1.value}) { dayCategory in
                            Image(systemName: Constants.TypeToSystemImageString[dayCategory.type]!)
                                .foregroundStyle(Color(AnalyticsView.colorFor(dayCategory.type)))
                            Text(String(describing: dayCategory.value))
                                .font(.caption)
                        }
                    }
                }
                .padding(3.5)
                .background(Color(.systemBackground))
                .glassEffect()
            }
        }

        private func dayIndex(from selectedDate: Date) -> Int {
            let cal = Calendar.current
            let end = cal.startOfDay(for: endDate)
            let selected = cal.startOfDay(for: selectedDate)
            // selected == end -> 0, selected one day before end -> 1, etc.
            let diff = cal.dateComponents([.day], from: selected, to: end).day ?? 0
            // Keep index in valid range for `categories(for:)`
            return min(max(diff, 0), dayPeriod - 1)
        }
    }

    private struct TotalCategorySpendingDonutChartView : View {
        @Binding var pageOffset: Int
        var dayPeriod: Int
        var items: [Expense]
        let chartHeight: CGFloat

        private func getMostSpentCategory() -> ExpenseType? {
            var mostSpentAmount: Decimal = 0
            var mostSpentType: ExpenseType? = nil

            let calendar = Calendar.current
            let todayStart = calendar.startOfDay(for: Date())
            let windowEnd = calendar.date(byAdding: .day, value: dayPeriod * pageOffset, to: todayStart) ?? todayStart
            let windowStart = calendar.date(byAdding: .day, value: -(dayPeriod - 1), to: windowEnd) ?? windowEnd

            for type in ExpenseType.allCases {
                let filteredItems: [Expense] = items.filter { expense in
                    guard expense.expenseType == type else { return false }
                    let ts = expense.timestamp
                    return ts >= windowStart && ts < calendar.date(byAdding: .day, value: 1, to: windowEnd)!
                }

                let sum = GetExpensesSum(items: filteredItems)
                if sum > mostSpentAmount {
                    mostSpentType = type
                    mostSpentAmount = sum
                }
            }

            return mostSpentType
        }

        var body: some View {
            Chart(ExpenseType.allCases, id: \.self) { type in
                let calendar = Calendar.current
                let todayStart = calendar.startOfDay(for: Date())
                let windowEnd = calendar.date(byAdding: .day, value: dayPeriod * pageOffset, to: todayStart) ?? todayStart
                let windowStart = calendar.date(byAdding: .day, value: -(dayPeriod - 1), to: windowEnd) ?? windowEnd

                let filteredItems: [Expense] = items.filter { expense in
                    guard expense.expenseType == type else { return false }
                    let ts = expense.timestamp
                    return ts >= windowStart && ts < calendar.date(byAdding: .day, value: 1, to: windowEnd)!
                }

                let categoryAmount = GetExpensesSum(items: filteredItems)

                SectorMark(
                    angle: .value("Category", categoryAmount),
                    innerRadius: .ratio(0.618),
                    angularInset: 1.5
                )
                .cornerRadius(5)
                .foregroundStyle(AnalyticsView.colorFor(type))
                .annotation(position: .overlay) {
                    if (categoryAmount > 0) {
                        Text(String(describing: categoryAmount))
                            .foregroundStyle(Color(.white))
                    }
                }
            }
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    let frame = geometry[chartProxy.plotFrame!]
                    VStack {
                        Text("Most spent on")
                            .font(.callout)
                            .foregroundStyle(.secondary)

                        let mostSpentCategory = getMostSpentCategory()
                        Label(mostSpentCategory?.rawValue ?? "N/A", systemImage: mostSpentCategory != nil ? Constants.TypeToSystemImageString[mostSpentCategory!]! : "")
                            .font(.title2.bold())
                            .foregroundStyle(mostSpentCategory != nil ? AnalyticsView.colorFor(mostSpentCategory!) : .primary)
                    }
                    .position(x: frame.midX, y: frame.midY)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: chartHeight)
            .padding()
        }
    }

    private struct RecordsView: View {
        var items: [Expense]
        var dayPeriod: Int
        var pageOffset: Int

        private var calendar: Calendar { .current }

        private var windowBounds: (start: Date, endInclusive: Date, endExclusive: Date) {
            let todayStart = calendar.startOfDay(for: Date())
            let endInclusive = calendar.date(byAdding: .day, value: dayPeriod * pageOffset, to: todayStart) ?? todayStart
            let start = calendar.date(byAdding: .day, value: -(dayPeriod - 1), to: endInclusive) ?? endInclusive
            let endExclusive = calendar.date(byAdding: .day, value: 1, to: endInclusive) ?? endInclusive
            return (start, endInclusive, endExclusive)
        }

        private var filteredItems: [Expense] {
            let bounds = windowBounds
            return items.filter { expense in
                expense.timestamp >= bounds.start && expense.timestamp < bounds.endExclusive
            }
        }

        private var biggestTransaction: Expense? {
            filteredItems.max {
                NSDecimalNumber(decimal: $0.amount).doubleValue < NSDecimalNumber(decimal: $1.amount).doubleValue
            }
        }

        private var mostSpentDaySummary: (day: Date, total: Decimal, topCategory: ExpenseType?, topCategoryAmount: Decimal)? {
            guard !filteredItems.isEmpty else { return nil }

            let groupedByDay = Dictionary(grouping: filteredItems) { expense in
                calendar.startOfDay(for: expense.timestamp)
            }

            guard let bestDayEntry = groupedByDay.max(by: { lhs, rhs in
                let lhsTotal = lhs.value.reduce(Decimal.zero) { $0 + $1.amount }
                let rhsTotal = rhs.value.reduce(Decimal.zero) { $0 + $1.amount }
                return lhsTotal < rhsTotal
            }) else {
                return nil
            }

            let day = bestDayEntry.key
            let dayItems = bestDayEntry.value
            let dayTotal = dayItems.reduce(Decimal.zero) { $0 + $1.amount }

            let topCategoryMap = dayItems.reduce(into: [ExpenseType: Decimal]()) { map, expense in
                map[expense.expenseType, default: .zero] += expense.amount
            }

            let topCategoryEntry = topCategoryMap.max(by: { $0.value < $1.value })

            return (
                day: day,
                total: dayTotal,
                topCategory: topCategoryEntry?.key,
                topCategoryAmount: topCategoryEntry?.value ?? .zero
            )
        }

        private func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }

        private func formatAmount(_ amount: Decimal) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
        }

        var body: some View {
            VStack(spacing: 10) {
                GroupBox("Most spent day") {
                    if let summary = mostSpentDaySummary {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(formatDate(summary.day))
                                .font(.subheadline.weight(.semibold))
                            Text("Total: \(formatAmount(summary.total))")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if let category = summary.topCategory {
                                HStack(spacing: 6) {
                                    Image(systemName: Constants.TypeToSystemImageString[category] ?? "questionmark.circle")
                                        .foregroundStyle(AnalyticsView.colorFor(category))
                                    Text("Top category: \(category.rawValue) (\(formatAmount(summary.topCategoryAmount)))")
                                        .font(.caption)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text("No records in this period")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                GroupBox("Biggest transaction") {
                    if let tx = biggestTransaction {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(tx.note != nil && !tx.note!.isEmpty ? tx.note! + ": " : "")\(formatAmount(tx.amount))")
                                .font(.subheadline.weight(.semibold))
                            Text(formatDate(tx.timestamp))
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 6) {
                                Image(systemName: Constants.TypeToSystemImageString[tx.expenseType] ?? "questionmark.circle")
                                    .foregroundStyle(AnalyticsView.colorFor(tx.expenseType))
                                Text("Category: \(tx.expenseType.rawValue)")
                                    .font(.caption)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text("No records in this period")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    let repository = ExpenseRepository.preview

    return AnalyticsView()
        .modelContainer(repository.container)
}
