//
//  TagCardView.swift
//  iFinanceHelper
//
//  Created by Vlad on 16/04/2026.
//

import Foundation
import SwiftUI
import Fit

struct TagCardView: View {

    @State private var isSelected: Bool = false

    let text: String

    @Binding var selectedText: String

    private var isInitiallySelected: Bool {
        selectedText.components(separatedBy: .whitespaces).contains(where: { $0 == text })
    }

    private func addTag() {
        var parts = selectedText.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        if !parts.contains(text) {
            parts.append(text)
            selectedText = parts.joined(separator: " ")
        }
    }

    private func removeTag() {
        let parts = selectedText.components(separatedBy: .whitespaces).filter { !$0.isEmpty && $0 != text }
        selectedText = parts.joined(separator: " ")
    }

    var body: some View {
        Toggle(isOn: $isSelected) {
            Text(text)
                .padding(2)
                .font(.system(size: 15))
        }
        .toggleStyle(.button)
        .onAppear {
            // Sync initial toggle state from selectedText
            isSelected = isInitiallySelected
        }
        .onChange(of: isSelected) { _, newValue in
            if newValue {
                // Selecting: add if not already present
                addTag()
            } else {
                // Deselecting: remove if present
                removeTag()
            }
        }
        .onChange(of: selectedText) { _, _ in
            // Keep toggle in sync with external changes to selectedText (e.g., Clear button)
            let nowSelected = selectedText.components(separatedBy: .whitespaces).contains(where: { $0 == text })
            if nowSelected != isSelected {
                isSelected = nowSelected
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedText: String = ""

    let tags = ["Test", "Groceries", "Transport", "Coffee", "Dining", "Health", "Subscriptions", "Books", "Gym", "GG", "Travel", "Rent"]

    Fit {
        ForEach(tags, id: \.self) { tag in
            TagCardView(text: tag, selectedText: $selectedText)
        }
    }
    Text(selectedText)
    Button("Clear") {
        selectedText = ""
    }
}
