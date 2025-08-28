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
    let colors: [Color]
    let makeFilter: () -> CIFilter
}

struct FilterSheet: View {
    @Binding var isPresented: Bool
    var onSelect: (CIFilter) -> Void

    private let options: [FilterOption] = [
        .init(
            title: "Caramel Fade",
            description: "A cozy, cinematic blend: a touch of sepia, a whisper of blur, and a soft vignette.",
            colors: [
                Color("CaramelFade1"),
                Color("CaramelFade2"),
                Color("CaramelFade3"),
                Color("CaramelFade4")
            ],
            makeFilter: { CIFilter.caramelFade() }
        ),
        .init(
            title: "Arctic Mist",
            description: "A crisp, cool look: daylight shift, teal hint, gentle vibrance, soft bloom, subtle vignette.",
            colors: [
                Color("ArcticMist1"),
                Color("ArcticMist2"),
                Color("ArcticMist3"),
                Color("ArcticMist4")
            ],
            makeFilter: { CIFilter.arcticMist() }
        ),
        .init(
            title: "Polar Radiance",
            description: "Brighter, icier look: stronger cool shift, white-point bias, clean bloom, crisp edges.",
            colors: [
                Color("PolarRadiance1"),
                Color("PolarRadiance2"),
                Color("PolarRadiance3"),
                Color("PolarRadiance4")
            ],
            makeFilter: { CIFilter.polarRadiance() }
        ),
        .init(
            title: "Patina Grain",
            description: "Cool-leaning vintage: lighter sepia, gentle cool shift, soft film grain, deeper vignette.",
            colors: [
                Color("PatinaGrain1"),
                Color("PatinaGrain2"),
                Color("PatinaGrain3"),
                Color("PatinaGrain4")
            ],
            makeFilter: { CIFilter.patinaGrain() }
        ),
        .init(
            title: "Retro Pixel",
            description: "Playful pixelation with posterized colors and a hint of vignette for retro readability.",
            colors: [
                Color("RetroPixel1"),
                Color("RetroPixel2"),
                Color("RetroPixel3"),
                Color("RetroPixel4")
            ],
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
                        CustomMeshGradientButton(
                            title: option.title,
                            description: option.description,
                            colors: option.colors
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
