//
//  CustomMeshGradientButton.swift
//  Retrobooth
//
//  Created by Emir Arı on 27.08.2025.
//

import SwiftUI

struct CustomMeshGradientButton: View {
    var title: String
    var description: String?
    var icon: String?
    var alignment: HorizontalAlignment = .leading
    var colors: [Color]
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            CustomMeshGradientButtonLabel(
                title: title,
                description: description,
                icon: icon,
                alignment: alignment,
                colors: colors
            )
        }
    }
}

struct CustomMeshGradientButtonLabel: View {
    var title: String
    var description: String?
    var icon: String?
    var alignment: HorizontalAlignment = .leading
    var colors: [Color]
    
    var body: some View {
        VStack(alignment: alignment, spacing: 4) {
            HStack {
                if let icon = icon {
                    Image(icon)
                        .resizable()
                        .frame(width: 24, height: 20)
                }
                
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            
            if let description = description {
                Text(description)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .center)
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(
            MeshGradient(
                width: 2,
                height: 2,
                points: [
                    [0, 0], [1, 0], [0, 1], [1, 1]
                ],
                colors: colors
            )
        )
        .cornerRadius(8)
    }
}


