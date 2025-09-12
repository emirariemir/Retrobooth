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
    @State private var pickerItems = [PhotosPickerItem]()
    @State private var originals = [CIImage]()
    @State private var selectedImages = [Image]()
    
    @State private var filter: CIFilter = CIFilter.arcticMist()
    @State private var currentFilterName: String = "Arctic Mist"
    @State private var filterNames: [String] = []
    @State private var currentIndex: Int = 0
    
    @State private var filterDialogShowing = false
    @State private var isProcessing = false
    
    @AppStorage("chosenFilterCount") var chosenFilterCount = 0
    @Environment(\.requestReview) var requestReview
    
    let context = CIContext()
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading) {
                    if selectedImages.count > 0 {
                        TabView(selection: $currentIndex) {
                            ForEach(selectedImages.indices, id: \.self) { i in
                                selectedImages[i]
                                    .resizable()
                                    .scaledToFit()
                                    .shadow(color: .black.opacity(0.4), radius: 8, x: 4, y: 4)
                                    .cornerRadius(8)
                                    .padding(.horizontal, 8)
                                    .tag(i)
                            }
                            
                            PhotosPicker(selection: $pickerItems, maxSelectionCount: 10, matching: .images) {
                                PhotoPickerContent(
                                    imageName: "change",
                                    title: "Done with those?",
                                    description: "Press here to start all over again."
                                )
                            }
                            .padding(.vertical, 20)
                            .buttonStyle(.plain)
                            .onChange(of: pickerItems, loadImage)
                            .tag(selectedImages.count)
                        }
                        .tabViewStyle(.page)
                        .indexViewStyle(.page(backgroundDisplayMode: .always))
                        .onChange(of: currentIndex) { oldIndex, newIndex in
                            withAnimation(.spring(response: 0.30, dampingFraction: 0.9)) {
                                if newIndex < filterNames.count {
                                    currentFilterName = filterNames[newIndex]
                                } else {
                                    currentFilterName = "Swipe back"
                                }
                            }
                        }
                    } else {
                        PhotosPicker(selection: $pickerItems, maxSelectionCount: 10, matching: .images) {
                            PhotoPickerContent(
                                imageName: "empty-folder",
                                title: "No picture selected. Tap here.",
                                description: "Pick up to 10 photos."
                            )
                        }
                        .buttonStyle(.plain)
                        .onChange(of: pickerItems, loadImage)
                    }
                    
                    Spacer()
                    
                    HStack {
                        FilterSelectorButton(filterName: currentFilterName, action: changeFilter)
                        
                        ShareLink(
                            items: selectedImages
                        ) { img in
                            SharePreview("Your Work", image: img)
                        } label: {
                            ExportButton(isDisabled: selectedImages.isEmpty)
                        }
                        .disabled(selectedImages.isEmpty)
                    }
                    
                }
                .padding([.horizontal, .bottom])
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Text("Retrobooth")
                            .font(.custom("FunnelDisplay-Medium", size: 32))
                            .foregroundColor(.primary)
                    }
                }
                .sheet(isPresented: $filterDialogShowing) {
                    FilterSheet(isPresented: $filterDialogShowing) { chosenFilter in
                        setFilter(chosenFilter)
                    }
                }
                
                if isProcessing {
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 12) {
                        
                        ProgressView()
                            .progressViewStyle(.circular)
                        
                        Text("Applying the magic…")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 24)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(radius: 12)
                }
            }
        }
        .permissionSheet([.photoLibrary])
    }
    
    func changeFilter() {
        filterDialogShowing = true
    }
    
    func loadImage() {
        Task {
            isProcessing = true
            selectedImages.removeAll()
            originals.removeAll()
            filterNames.removeAll()
            currentIndex = 0
            
            guard !pickerItems.isEmpty else {
                isProcessing = false
                return
            }
            
            for item in pickerItems {
                do {
                    guard let data = try await item.loadTransferable(type: Data.self),
                          let ui = UIImage(data: data) else { continue }
                    
                    guard let ci = CIImage(image: ui)?
                        .oriented(forExifOrientation: exifOrientation(ui.imageOrientation)) else { continue }
                    
                    originals.append(ci)
                    
                    filter.setValue(ci, forKey: kCIInputImageKey)
                    if let processed = applyProcessing() {
                        selectedImages.append(processed)
                    }
                    let initialName = determineFilterName(filter.name)
                    filterNames.append(initialName)
                } catch {
                    print("Failed to load image: \(error.localizedDescription)")
                    originals.append(CIImage(color: .clear).cropped(to: .init(x: 0, y: 0, width: 1, height: 1)))
                    selectedImages.append(Image(systemName: "exclamationmark.triangle"))
                }
            }
            
            isProcessing = false
        }
    }
    
    
    func applyProcessing() -> Image?  {
        guard let outputImage =  filter.outputImage else { return nil }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        let uiImage = UIImage(cgImage: cgImage)
        let finalImg = Image(uiImage: uiImage)
        return finalImg
    }
    
    @MainActor
    func setFilter(_ chosenFilter: CIFilter) {
        filter = chosenFilter
        filterDialogShowing = false
        chosenFilterCount += 1
        
        currentFilterName = determineFilterName(chosenFilter.name)
        
        if currentIndex < filterNames.count {
            let newName = determineFilterName(chosenFilter.name)
            print(currentIndex)
            filterNames[currentIndex] = newName
        } else {
            currentFilterName = "Swipe back"
        }
        
        guard originals.indices.contains(currentIndex),
              selectedImages.indices.contains(currentIndex) else { return }
        
        let ci = originals[currentIndex]
        filter.setValue(ci, forKey: kCIInputImageKey)
        
        if let processed = applyProcessing() {
            selectedImages[currentIndex] = processed
        }
        
        if chosenFilterCount >= 40 {
            requestReview()
        }
    }
    
    
    func determineFilterName(_ filterName: String) -> String {
        switch filterName {
        case "CIArcticMist":
            return "Arctic Mist"
        case "CICaramelFade":
            return "Caramel Fade"
        case "CIPatinaGrain":
            return "Patina Grain"
        case "CIPolarRadiance":
            return "Polar Radiance"
        case "CISilverGrit":
            return "Silver Grit"
        case "CIRetroPixel":
            return "Retro Pixel"
        default:
            return "Unknown Filter"
        }
    }
    
    func exifOrientation(_ orientation: UIImage.Orientation) -> Int32 {
        switch orientation {
        case .up: return 1
        case .down: return 3
        case .left: return 8
        case .right: return 6
        case .upMirrored: return 2
        case .downMirrored: return 4
        case .leftMirrored: return 5
        case .rightMirrored: return 7
        @unknown default: return 1
        }
    }
}

#Preview {
    ContentView()
}
