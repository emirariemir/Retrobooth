//
//  ExportButton.swift
//  Retrobooth
//
//  Created by Emir Arı on 28.08.2025.
//

import SwiftUI

struct ExportButton: View {
    var isDisabled: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isDisabled ? .gray : .black)
            Text("Export")
                .font(.custom("FunnelDisplay-Medium", size: 16))
                .foregroundStyle(isDisabled ? .gray : .black)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(backgroundView(isDisabled: isDisabled))
        .cornerRadius(64)
        .background(
            isDisabled ? nil :
            RoundedRectangle(cornerRadius: 64)
                .stroke(.white, lineWidth: 4)
        )
    }
    
    @ViewBuilder
    private func backgroundView(isDisabled: Bool) -> some View {
        if isDisabled {
            RoundedRectangle(cornerRadius: 64)
                .foregroundStyle(.white.opacity(0.8))
        } else {
            AnimatedMeshGradientView()
                .overlay(
                    RoundedRectangle(cornerRadius: 64)
                        .foregroundStyle(.white)
                        .blur(radius: 32)
                )
        }
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
                bobble ? Color("SoftGrey") : Color("SoftGreen"),
                bobble ? Color("SoftPurple") : Color("SoftGreen"),
                wobble ? Color("SoftPurple") : Color("SoftPink"),
                wobble ? Color("SoftGreen") : Color("SoftGrey"),
                wobble ? Color("SoftPink") : Color("SoftPurple"),
                wobble ? Color("SoftPink") : Color("SoftGreen"),
                wobble ? Color("SoftGreen") : Color("SoftPink"),
                wobble ? Color("SoftGreen") : Color("SoftGrey"),
                bobble ? Color("SoftPink") : Color("SoftGreen")
            ]
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                wobble.toggle()
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                bobble.toggle()
            }
        }
    }
}

