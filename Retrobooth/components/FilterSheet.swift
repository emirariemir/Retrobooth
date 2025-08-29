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
    let goesGoodWithDesc: String
    let colors: [Color]
    let filterName: String
    let makeFilter: () -> CIFilter
}

struct FilterSheet: View {
    @Binding var isPresented: Bool
    var onSelect: (CIFilter) -> Void
    
    private let options: [FilterOption] = [
        .init(
            title: "Caramel Fade",
            description: "A cozy, cinematic blend: a touch of sepia, a whisper of blur, and a soft vignette.",
            goesGoodWithDesc: "Perfect for warm portraits, cozy café moments, golden hour light, and scenes where you want a soft nostalgic glow.",
            colors: [
                Color("CaramelFade1"),
                Color("CaramelFade2"),
                Color("CaramelFade3"),
                Color("CaramelFade4")
            ],
            filterName: "caramelFade",
            makeFilter: { CIFilter.caramelFade() }
        ),
        .init(
            title: "Arctic Mist",
            description: "A crisp, cool look: daylight shift, teal hint, gentle vibrance, soft bloom, subtle vignette.",
            goesGoodWithDesc: "Works beautifully with snowy landscapes, fresh seaside captures, minimalist setups, or any photo that needs a clean, airy vibe.",
            colors: [
                Color("ArcticMist1"),
                Color("ArcticMist2"),
                Color("ArcticMist3"),
                Color("ArcticMist4")
            ],
            filterName: "arcticMist",
            makeFilter: { CIFilter.arcticMist() }
        ),
        .init(
            title: "Polar Radiance",
            description: "Brighter, icier look: stronger cool shift, white-point bias, clean bloom, crisp edges.",
            goesGoodWithDesc: "Best paired with night skies, glacial scenery, futuristic architecture, or shots that need sharp highlights and radiant energy.",
            colors: [
                Color("PolarRadiance1"),
                Color("PolarRadiance2"),
                Color("PolarRadiance3"),
                Color("PolarRadiance4")
            ],
            filterName: "polarRadiance",
            makeFilter: { CIFilter.polarRadiance() }
        ),
        .init(
            title: "Patina Grain",
            description: "Cool-leaning vintage: lighter sepia, gentle cool shift, soft film grain, deeper vignette.",
            goesGoodWithDesc: "Ideal for moody street photography, retro interiors, timeless portraits, and anything that calls for a film-like vintage texture.",
            colors: [
                Color("PatinaGrain1"),
                Color("PatinaGrain2"),
                Color("PatinaGrain3"),
                Color("PatinaGrain4")
            ],
            filterName: "patinaGrain",
            makeFilter: { CIFilter.patinaGrain() }
        ),
        .init(
            title: "Retro Pixel",
            description: "Playful pixelation with posterized colors and a hint of vignette for retro readability.",
            goesGoodWithDesc: "Great for game screenshots, neon-lit selfies, playful edits, or any scene where a nostalgic 8-bit arcade mood fits the story.",
            colors: [
                Color("RetroPixel1"),
                Color("RetroPixel2"),
                Color("RetroPixel3"),
                Color("RetroPixel4")
            ],
            filterName: "retroPixel",
            makeFilter: { CIFilter.retroPixel() }
        ),
    ]
    
    
    @State private var selection: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Choose a Filter")
                .font(.custom("FunnelDisplay-Medium", size: 16))
            Text("Swipe through filters to find the one for you.")
                .font(.custom("FunnelDisplay-Light", size: 12))
            
            TabView(selection: $selection) {
                ForEach(options.indices, id: \.self) { idx in
                    FilterCardView(
                        title: options[idx].title,
                        description: options[idx].description,
                        filterName: options[idx].filterName
                    )
                    .padding()
                    .tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Spacer(minLength: 8)
            
            CustomButton(
                title: "Select This Filter",
                alignment: .center,
                backgroundColor: .primary
            ) {
                guard options.indices.contains(selection) else { return }
                onSelect(options[selection].makeFilter())
                isPresented = false
            }
            .disabled(options.isEmpty)
        }
        .padding()
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
