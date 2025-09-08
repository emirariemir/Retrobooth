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
    
    @State private var sheetHeight: CGFloat = .zero
    
    var body: some View {
        ZStack {
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
                        .padding(.horizontal)
                        .tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .frame(height: 280)
                
                if options.count > 1 {
                    PageDots(count: options.count, selection: $selection)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom)
                }
                
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
            .onGeometryChange(for: CGSize.self) {
                $0.size
            } action: { newValue in
                sheetHeight = newValue.height
            }
            .presentationDragIndicator(.visible)
        }
        .presentationDetents([.height(sheetHeight)])
    }
}

// MARK: - Reusable dots
struct PageDots: View {
    let count: Int
    @Binding var selection: Int
    var dotSize: CGFloat = 8
    var activeWidth: CGFloat = 20
    var spacing: CGFloat = 8
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<count, id: \.self) { i in
                Capsule(style: .continuous)
                    .fill(i == selection ? Color.primary.opacity(0.9) : Color.primary.opacity(0.25))
                    .frame(width: i == selection ? activeWidth : dotSize,
                           height: dotSize)
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selection)
                    .contentShape(Rectangle())
                    .onTapGesture { selection = i }
            }
        }
    }
}

