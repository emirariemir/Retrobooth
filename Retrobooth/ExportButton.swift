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
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
            Text("Export")
                .font(.custom("FunnelDisplay-Medium", size: 16))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(
            AnimatedMeshGradientView()
                .mask(
                    RoundedRectangle(cornerRadius: 64)
                        .stroke(lineWidth: 12)
                        .blur(radius: 8)
                )
        )
        .background(.black)
        .cornerRadius(64)
        .background(
            RoundedRectangle(cornerRadius: 64)
                .stroke(.white.opacity(0.9), lineWidth: 2)
        )
    }
}

struct AnimatedMeshGradientView: View {
    @State private var wobble = false
    @State private var bobble = false

    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0.0, 0.0], [bobble ? 0.5 : 1.0, 0.0], [1.0, 0.0],
                [0.0, 0.5], wobble ? [0.1, 0.5] : [0.8, 0.2], [1.0, -0.5],
                [0.0, 1.0], [1.0, bobble ? 2.0 : 1.0], [1.0, 1.0]
            ],
            colors: [
                bobble ? .red : .mint,
                bobble ? .yellow : .cyan,
                .orange,
                wobble ? .blue : .red,
                wobble ? .cyan : .white,
                wobble ? .red : .purple,
                wobble ? .red : .cyan,
                wobble ? .mint : .blue,
                bobble ? .red : .blue
            ]
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 11).repeatForever(autoreverses: true)) {
                wobble.toggle()
            }
            withAnimation(.easeInOut(duration: 13).repeatForever(autoreverses: true)) {
                bobble.toggle()
            }
        }
    }
}

