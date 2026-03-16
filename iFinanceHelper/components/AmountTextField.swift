//
//  AmountTextField.swift
//  iFinanceHelper
//
//  Created by Vlad on 15/03/2026.
//

import SwiftUI


struct AmountTextField: View {
    @Binding var amount: Decimal

    var body: some View {

        VStack {

            ZStack(alignment: .leading) {

                // Card Background
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 140)

                VStack(alignment: .leading, spacing: 10) {

                    // Icon + Label
                    HStack {
                        Image(systemName: "dollarsign")
                            .foregroundColor(.gray)

                        Text("Amount")
                            .foregroundColor(.gray)
                            .font(.title3)
                    }

                    // Amount Input
                    TextField("0.00", value: $amount, format: .number)
                        .font(.system(size: 42, weight: .light))
                        .keyboardType(.decimalPad)
                }
                .padding(20)
            }
            .glassEffect(.regular, in: .rect(cornerRadius: 20))
            .padding()
        }
    }
}

#Preview {
    AmountTextField(amount: Binding<Decimal>.constant(25.0))
}
