//
//  ContentView.swift
//  Retrobooth
//
//  Created by Emir Arı on 25.08.2025.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import StoreKit
import SwiftUI

struct ContentView: View {
    @StateObject private var vm = ContentVM()
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var showLibrary = false
    @State private var showingFilterSheet = false
    @Environment(\.requestReview) private var requestReview
    
    var body: some View {
        NavigationStack {
            ZStack {
                content
                if vm.isProcessing { LoadingOverlay(text: "Applying the magic…") }
                if let toast = vm.toast { ToastView(toast: toast) { vm.toast = nil } }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { actions }
        }
        .permissionSheet([.photoLibrary])
        .photosPicker(isPresented: $showLibrary, selection: $pickerItems, maxSelectionCount: 10, matching: .images)
        .task(id: pickerItems) {
            guard !pickerItems.isEmpty else { return }
            let width = UIScreen.main.bounds.width * 3
            vm.load(pickerItems: pickerItems, targetWidth: width)
        }
    }
    
    @ToolbarContentBuilder
    private var actions: some ToolbarContent {
        if #available(iOS 26.0, *) {
            ToolbarItem(placement: .topBarLeading) {
                Text("Retrobooth")
                    .font(.custom("FunnelDisplay-Medium", size: 24))
                    .foregroundColor(.primary)
                    .fixedSize()
            }
            .sharedBackgroundVisibility(.hidden)
        } else {
            ToolbarItem(placement: .navigation) {
                Text("Retrobooth")
                    .font(.custom("FunnelDisplay-Medium", size: 24))
                    .foregroundColor(.primary)
            }
        }
        
        ToolbarItem(placement: .primaryAction) {
            Menu {
                Button("Edit selections") { showLibrary = true }
                Button("Remove photos", role: .destructive) {
                    withAnimation { pickerItems.removeAll(); vm.items.removeAll() }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.white)
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if vm.items.isEmpty {
            PhotosPicker(selection: $pickerItems, maxSelectionCount: 10, matching: .images) {
                PhotoPickerContent(
                    imageName: "empty-folder",
                    title: "No picture selected. Tap here.",
                    description: "Pick up to 10 photos."
                )
            }.buttonStyle(.plain)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                TabView(selection: $vm.currentIndex) {
                    ForEach(Array(vm.items.enumerated()), id: \.element.id) { i, item in
                        Group {
                            if let cg = item.processed {
                                Image(uiImage: UIImage(cgImage: cg))
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                ProgressView()
                            }
                        }
                        .shadow(color: .black.opacity(0.4), radius: 8, x: 4, y: 4)
                        .cornerRadius(8)
                        .padding(.horizontal, 8)
                        .tag(i)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                HStack {
                    FilterSelectorButton(
                        filterName: vm.items[vm.currentIndex].appliedFilter.displayName,
                        action: { showingFilterSheet = true },
                        isDisabled: vm.items.isEmpty
                    )
                    .animation(.snappy(duration: 0.25), value: vm.currentIndex)
                    .disabled(vm.items.isEmpty)
                    
                    
                    if let ui: UIImage = vm.currentUIImage() {
                        ShareLink(items: [Image(uiImage: ui)]) { img in
                            SharePreview("Your Work", image: img)
                        } label: {
                            ExportButton(isDisabled: false)
                        }
                    } else {
                        ExportButton(isDisabled: true).disabled(true)
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .sheet(isPresented: $showingFilterSheet) {
                FilterSheetCompat( // renamed this, maybe rename file later
                    isPresented: $showingFilterSheet,
                    current: vm.items[vm.currentIndex].appliedFilter
                ) { picked in
                    vm.apply(picked)
                    maybeAskForReview()
                }
            }
        }
    }
    
    private func maybeAskForReview() {
        vm.chosenFilterCount += 1
        print("chosen filter count: \(vm.chosenFilterCount)")
        if vm.chosenFilterCount % 12 == 0, AppReviewManager.shared.canPrompt() {
            requestReview()
            AppReviewManager.shared.recordPrompt()
        }
    }
}

#Preview {
    ContentView()
}
