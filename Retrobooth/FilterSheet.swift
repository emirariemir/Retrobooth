//
//  FilterSheet.swift
//  Retrobooth
//
//  Created by Emir Arı on 27.08.2025.
//

import SwiftUI
import CoreImage

struct FilterOption: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let color: Color
    let makeFilter: () -> CIFilter
}

struct FilterSheet: View {
    @Binding var isPresented: Bool
    var onSelect: (CIFilter) -> Void

    private let options: [FilterOption] = [
        .init(
            title: "Caramel Fade",
            description: "A cozy, cinematic blend: a touch of sepia, a whisper of blur, and a soft vignette.",
            color: .brown,
            makeFilter: { CIFilter.caramelFade() }
        ),
        .init(
            title: "Arctic Mist",
            description: "A crisp, cool look: daylight shift, teal hint, gentle vibrance, soft bloom, subtle vignette.",
            color: .blue,
            makeFilter: { CIFilter.arcticMist() }
        ),
        .init(
            title: "Polar Radiance",
            description: "Brighter, icier look: stronger cool shift, white-point bias, clean bloom, crisp edges.",
            color: .teal,
            makeFilter: { CIFilter.polarRadiance() }
        ),
        .init(
            title: "Patina Grain",
            description: "Cool-leaning vintage: lighter sepia, gentle cool shift, soft film grain, deeper vignette.",
            color: .indigo,
            makeFilter: { CIFilter.patinaGrain() }
        ),
        .init(
            title: "Retro Pixel",
            description: "Playful pixelation with posterized colors and a hint of vignette for retro readability.",
            color: .cyan,
            makeFilter: { CIFilter.retroPixel() }
        ),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select a Filter")
                .font(.title2.weight(.bold))

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(options) { option in
                        CustomButton(
                            title: option.title,
                            description: option.description,
                            backgroundColor: option.color
                        ) {
                            onSelect(option.makeFilter())
                        }
                    }
                }
                .padding(.top, 4)
            }

            Spacer(minLength: 8)

            CustomButton(
                title: "Close",
                alignment: .center,
                backgroundColor: .red
            ) {
                isPresented = false
            }
        }
        .padding()
        .presentationDragIndicator(.visible)
    }
}
