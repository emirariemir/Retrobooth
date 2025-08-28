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

struct FilterSelectorButton: View {
    var filterName: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading) {
                    Text("Selected filter:")
                        .font(.footnote)
                        .foregroundStyle(.white)
                        .opacity(0.7)
                    Text(filterName)
                        .font(.system(.title3, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                Image(systemName: "chevron.up")
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct CustomButtonLabel: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
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
                    .foregroundStyle(colorScheme == .light ? .white : .black)
            }

            if let description = description {
                Text(description)
                    .font(.caption)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(colorScheme == .light ? .white : .black)
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

