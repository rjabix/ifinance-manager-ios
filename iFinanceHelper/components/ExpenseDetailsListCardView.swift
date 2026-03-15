import SwiftUI
import SwiftData

struct ExpenseDetailsListCardView: View {

    let item: Expense

    init(item: Expense) {
        self.item = item
    }

    var body: some View {
        NavigationLink {
            Text("EditExpenseView")
        } label: {
            // the card in the list
            ExpenseLinkCard(item: item)
        }
        .buttonStyle(.plain)
    }

    private struct ExpenseLinkCard: View {

        let item: Expense

        init(item: Expense) {
            self.item = item
        }

        var body: some View {
            HStack(spacing: 14) {
                ZStack {
                    Image(systemName: Constants.TypeToSystemImageString[item.expenseType]!)
                        .font(.system(size: 22))
                }
                .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 4) {
                    Text(cardTitle)
                        .font(.headline)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Text(amountText)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.vertical, 6)
        }

        private var cardTitle: String {
            let trimmed = item.note?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return trimmed.isEmpty ? "Expense" : trimmed
        }

        private var subtitle: String {
            let dateText = item.timestamp.formatted(
                Date.FormatStyle(date: .abbreviated, time: .shortened)
                    .year(.omitted))
            return dateText
        }

        private var amountText: String {
            item.amount.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
        }
    }
}

#Preview {
    let repository = ExpenseRepository.preview
    NavigationStack {
        List {
            ExpenseDetailsListCardView(
                item: Expense(amount: 25.00, expenseType: .food)
            )
        }
    }
    .modelContainer(repository.container)
}
