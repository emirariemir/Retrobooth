//
//  FilterSheet.swift
//  Retrobooth
//
//  Created by Emir Arı on 27.08.2025.
//

import SwiftUI

struct FilterSheetCompat: View {
    @Binding var isPresented: Bool
    var current: FilterKind
    var onPick: (FilterKind) -> Void

    private let kinds = FilterKind.allCases
    @State private var currentIndex: Int = 0
    @State private var sheetHeight: CGFloat = .zero

    init(isPresented: Binding<Bool>, current: FilterKind, onPick: @escaping (FilterKind) -> Void) {
        self._isPresented = isPresented
        self.current = current
        self.onPick = onPick
        // _currentIndex will be set in .onAppear to ensure safe index lookup
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Pick a filter")
                    .font(.custom("FunnelDisplay-Medium", size: 20))

                Text("Swipe through filters and pick the one that feels right.")
                    .font(.custom("FunnelDisplay-Light", size: 16))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                TabView(selection: $currentIndex) {
                    ForEach(kinds.indices, id: \.self) { idx in
                        let kind = kinds[idx]
                        FilterCardView(
                            title: kind.displayName,
                            description: kind.description,
                            filterName: kind.cardFilterName
                        )
                        .padding(.horizontal)
                        .tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .frame(height: 280)

                if kinds.count > 1 {
                    PageDots(count: kinds.count, selection: $currentIndex)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom)
                }

                CustomButton(
                    title: "Apply filter",
                    alignment: .center,
                    backgroundColor: .white
                ) {
                    guard kinds.indices.contains(currentIndex) else { return }
                    onPick(kinds[currentIndex])
                    isPresented = false
                }
                .disabled(kinds.isEmpty)
            }
            .padding()
            .onAppear {
                if let start = kinds.firstIndex(of: current) {
                    currentIndex = start
                } else {
                    currentIndex = 0
                }
            }
            .onGeometryChange(for: CGSize.self) { $0.size } action: { newValue in
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

