//
//  ExportButton.swift
//  Retrobooth
//
//  Created by Emir Arı on 28.08.2025.
//

import SwiftUI

struct ExportButton: View {
    var body: some View {
        HStack {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
            Text("Export")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
        }
        .padding()
        .background(
            MeshGradient(
                width: 2,
                height: 2,
                points: [
                    [0, 0], [1, 0], [0, 1], [1, 1]
                ],
                colors: [
                    Color("SoftGreen"),
                    Color("SoftGrey"),
                    Color("SoftPink"),
                    Color("SoftPurple")
                ]
            )
        )
        .cornerRadius(64)
    }
}
