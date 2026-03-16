//
//  NoteField.swift
//  iFinanceHelper
//
//  Created by Vlad on 15/03/2026.
//

import SwiftUI

struct NoteField: View {
    @Binding var note: String?

    var body: some View {

        HStack(spacing: 12) {

            Image(systemName: "note")
                .font(.title2)
                .padding([.leading])

            TextField("Note", text: $note ?? "")
                .font(.title3)
                .fontWeight(.semibold)

            Spacer()

        }
        .frame(height: 80)
        .cornerRadius(25)
        .glassEffect(.regular, in: .rect(cornerRadius: 25))
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [2]))
        )
        .padding([.horizontal])
    }
}


#Preview {
    NoteFieldPreviewContainer()
}

private struct NoteFieldPreviewContainer: View {
    @State private var note: String? = nil

    var body: some View {
        NoteField(note: $note)
            .padding()
    }
}
