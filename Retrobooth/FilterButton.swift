//
//  FilterButton.swift
//  Retrobooth
//
//  Created by Emir Arı on 26.08.2025.
//

import SwiftUI

struct FilterButton: View {
    var title: String
    var description: String?
    var alignment: HorizontalAlignment = .leading
    var backgroundColor: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: alignment, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                if let description = description {
                    Text(description)
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .center)
            .padding(.vertical, 12)
            .padding(.horizontal)
            .background(backgroundColor)
            .cornerRadius(8)
        }
    }
}
