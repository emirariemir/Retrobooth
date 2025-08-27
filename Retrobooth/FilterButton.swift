//
//  FilterButton.swift
//  Retrobooth
//
//  Created by Emir Arı on 26.08.2025.
//

import SwiftUI

struct CustomButton: View {
    var title: String
    var description: String?
    var icon: String?
    var alignment: HorizontalAlignment = .leading
    var backgroundColor: Color
    var isDisabled: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            CustomButtonLabel(
                title: title,
                description: description,
                icon: icon,
                alignment: alignment,
                backgroundColor: backgroundColor,
                isDisabled: isDisabled
            )
        }
        .disabled(isDisabled)
    }
}

struct CustomButtonLabel: View {
    var title: String
    var description: String?
    var icon: String?
    var alignment: HorizontalAlignment = .leading
    var backgroundColor: Color
    var isDisabled: Bool = false

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
                    .font(.caption)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .center)
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(isDisabled ? backgroundColor.opacity(0.5) : backgroundColor)
        .cornerRadius(8)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

