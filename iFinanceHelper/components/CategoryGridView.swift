//
//  CategoryGridView.swift
//  iFinanceHelper
//
//  Created by Vlad on 15/03/2026.
//

import SwiftUI


struct CategoryGridView: View {

        @Binding var expenseType: ExpenseType?

        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        var body: some View {

            LazyVGrid(columns: columns, spacing: 20) {

                ForEach(ExpenseType.allCases, id: \.self) { type in

                    let isSelected = $expenseType.wrappedValue == type

                    Button {
                        if (expenseType == type) {
                            $expenseType.wrappedValue = nil
                        }
                        else {
                            $expenseType.wrappedValue = type
                        }
                    } label: {

                        VStack(spacing: 10) {

                            Image(systemName: Constants.TypeToSystemImageString[type]!)
                                .font(.system(size: 32))

                            Text(Constants.TypeToNameString[type]!)
                                .font(.headline)
                        }
                        .frame(height: 90)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(isSelected ? Color.blue.opacity(0.2) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                        )
                        .opacity(isSelected || $expenseType.wrappedValue == nil ? 1 : 0.4)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular, in: .rect(cornerRadius: 20))
                }
            }
            .padding()
        }
    }

#Preview {
    PreviewContainer()
}

private struct PreviewContainer: View {
    @State private var selectedExpenseType: ExpenseType? = nil

    var body: some View {
        CategoryGridView(expenseType: $selectedExpenseType)
    }
}
