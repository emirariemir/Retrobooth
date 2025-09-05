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
    let description: LocalizedStringKey
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
            filterName: "caramelFade",
            makeFilter: { CIFilter.caramelFade() }
        ),
        .init(
            title: "Arctic Mist",
            description: "Daylight shift, teal hint, gentle vibrance, soft bloom, subtle vignette.",
            filterName: "arcticMist",
            makeFilter: { CIFilter.arcticMist() }
        ),
        .init(
            title: "Polar Radiance",
            description: "Brighter, icier look: stronger cool shift, white-point bias, clean bloom, crisp edges.",
            filterName: "polarRadiance",
            makeFilter: { CIFilter.polarRadiance() }
        ),
        .init(
            title: "Patina Grain",
            description: "Cool-leaning vintage: lighter sepia, gentle cool shift, soft film grain, deeper vignette.",
            filterName: "patinaGrain",
            makeFilter: { CIFilter.patinaGrain() }
        ),
        .init(
            title: "Silver Grit",
            description: "Monochrome grit: deep desaturation, crisp contrast, heavy film grain, subtle vignette.",
            filterName: "silverGrit",
            makeFilter: { CIFilter.silverGrit() }
        ),
        .init(
            title: "Retro Pixel",
            description: "Playful pixelation with posterized colors and a hint of vignette for retro readability.",
            filterName: "retroPixel",
            makeFilter: { CIFilter.retroPixel() }
        ),
    ]
    
    
    @State private var selection: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Pick a filter")
                .font(.custom("FunnelDisplay-Medium", size: 20))
            Text("Swipe through filters and pick the one that feels right.")
                .font(.custom("FunnelDisplay-Light", size: 16))
            
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
                title: "Apply filter",
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
