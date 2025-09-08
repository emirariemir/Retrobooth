//
//  FilterCardView.swift
//  Retrobooth
//
//  Created by Emir Arı on 29.08.2025.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct FilterCardView: View {
    // Public API
    let title: String
    let description: LocalizedStringKey
    let filterName: String

    // Layout tunables
    private let circleSize: CGFloat = 126
    private let cornerRadius: CGFloat = 16
    private let padding: CGFloat = 14

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(.systemTeal).opacity(0.35),
                            Color(.systemIndigo).opacity(0.35)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    Image("flower")
                        .resizable()
                        .scaledToFill()
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.primary)
                        .accessibilityHidden(true)
                    
                }
                .frame(width: circleSize, height: circleSize)
                .clipShape(Circle())
                .overlay(
                    Circle().strokeBorder(.quaternary, lineWidth: 1)
                )
                .shadow(radius: 4, y: 2)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 20, weight: .semibold))
                
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(.systemTeal).opacity(0.35),
                            Color(.systemIndigo).opacity(0.35)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    Image("flower-\(filterName)")
                        .resizable()
                        .scaledToFill()
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.primary)
                        .accessibilityHidden(true)
                }
                .frame(width: circleSize, height: circleSize)
                .clipShape(Circle())
                .overlay(
                    Circle().strokeBorder(.quaternary, lineWidth: 1)
                )
                .shadow(radius: 4, y: 2)
            }

            VStack(spacing: 6) {
                Text(title)
                    .font(.custom("FunnelDisplay-Medium", size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)

                Text(description)
                    .font(.custom("FunnelDisplay-Light", size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 8)
        }
        .padding(padding)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.thickMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(.quaternary, lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text(description))
    }
}

// MARK: - Preview
struct FilterCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FilterCardView(
                title: "Caramel Fade",
                description: "A cozy, cinematic blend: a touch of sepia, a whisper of blur, and a soft vignette.",
                filterName: "caramelFade"
            )
            .padding()
            .previewDisplayName("Light")

            FilterCardView(
                title: "Arctic Mist",
                description: "Cool contrast with crisp highlights.",
                filterName: "arcticMist"
            )
            .padding()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark")
        }
        .previewLayout(.sizeThatFits)
    }
}

