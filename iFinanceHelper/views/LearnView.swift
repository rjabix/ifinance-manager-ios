//
//  LearnView.swift
//  iFinanceHelper
//
//  Created by Vlad on 29/03/2026.
//

import SwiftUI
import AVKit

struct LearnView: View {

    private struct VideoView : View {
        var body: some View {
            if let url = Bundle.main.url(forResource: "guide", withExtension: "mp4") {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                // Fallback UI if the video isn’t found
                Text("Video not found")
                    .frame(height: 220)
                    .frame(maxWidth: .infinity)
                    .background(.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VideoView()
                // Section 1: Text left, Image right
                LearnSection(
                    title: "Build a simple budget",
                    subtitle: "Start by allocating your income across essentials, savings, and wants.",
                    imageSystemName: "chart.pie.fill",
                    imageTint: .teal,
                    layout: .textLeftImageRight
                )

                // Section 2: Image left, Text right
                LearnSection(
                    title: "Track spending consistently",
                    subtitle: "Record purchases daily and review your categories weekly.",
                    imageSystemName: "list.bullet.rectangle.portrait.fill",
                    imageTint: .indigo,
                    layout: .imageLeftTextRight
                )

                // Section 3: Text left, Image right
                LearnSection(
                    title: "Grow an emergency fund",
                    subtitle: "Aim for 3–6 months of essential expenses in a safe account.",
                    imageSystemName: "lifepreserver.fill",
                    imageTint: .orange,
                    layout: .textLeftImageRight
                )
            }
            .padding()
        }
        .navigationTitle("Learn")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Alternating Section

private struct LearnSection: View {
    enum Layout { case textLeftImageRight, imageLeftTextRight }

    var title: String
    var subtitle: String
    var imageSystemName: String
    var imageTint: Color
    var layout: Layout

    var body: some View {
            HStack(alignment: .center, spacing: 16) {
                if layout == .textLeftImageRight {
                    sectionText
                    sectionImage
                } else {
                    sectionImage
                    sectionText
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }

    private var sectionText: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var sectionImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(imageTint.opacity(0.12))
            Image(systemName: imageSystemName)
                .resizable()
                .scaledToFit()
                .foregroundStyle(imageTint)
                .padding(16)
        }
        .frame(width: 140, height: 120)
    }
}

#Preview {
    NavigationStack {
        LearnView()
    }
}
