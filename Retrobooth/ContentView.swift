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
    @State private var selectedImages = [Image]()
    @State private var pickerItems = [PhotosPickerItem]()
    @State private var filterDialogShowing = false
    @State private var currentFilterName: String = "Arctic Mist"
    
    @AppStorage("chosenFilterCount") var chosenFilterCount = 0
    @Environment(\.requestReview) var requestReview
    
    @State private var filter: CIFilter = CIFilter.arcticMist()
    let context = CIContext()
    
    @State private var isProcessing = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading) {
                    if selectedImages.count > 0 {
                        TabView {
                            ForEach(0..<selectedImages.count, id: \.self) { i in
                                selectedImages[i]
                                    .resizable()
                                    .scaledToFit()
                                    .shadow(color: .black.opacity(0.4), radius: 8, x: 4, y: 4)
                                    .cornerRadius(8)
                                    .padding(.horizontal, 8)
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
                        }
                        .tabViewStyle(.page)
                        .indexViewStyle(.page(backgroundDisplayMode: .always))
                        
                    } else {
                        PhotosPicker(selection: $pickerItems, maxSelectionCount: 10, matching: .images) {
                            PhotoPickerContent(
                                imageName: "empty-folder",
                                title: "No picture, press me.",
                                description: "You can select up to 10 photos."
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
                            SharePreview("Your beautiful image", image: img)
                        } label: {
                            ExportButton()
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
                        
                        Text("Processing photos…")
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
    }
    
    func changeFilter() {
        filterDialogShowing = true
    }
    
    func loadImage() {
        Task {
            await MainActor.run {
                isProcessing = true
                selectedImages.removeAll()
            }
            
            let count = pickerItems.count
            guard count > 0 else {
                await MainActor.run {
                    isProcessing = false
                }
                return
            }
            
            for (_, item) in pickerItems.enumerated() {
                do {
                    guard let imageData = try await item.loadTransferable(type: Data.self),
                          let inputImage = UIImage(data: imageData) else {
                        continue
                    }
                    
                    // Prepare CI input off main thread
                    let beginImage = CIImage(image: inputImage)?
                        .oriented(forExifOrientation: exifOrientation(inputImage.imageOrientation))
                    
                    filter.setValue(beginImage, forKey: kCIInputImageKey)
                    
                    if let processed = applyProcessing() {
                        await MainActor.run {
                            selectedImages.append(processed)
                        }
                    }
                } catch {
                    // TODO: handle here
                }
            }
            
            await MainActor.run {
                isProcessing = false
            }
        }
    }
    
    
    func applyProcessing() -> Image?  {
        guard let outputImage =  filter.outputImage else { return nil }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
        else { return nil }
        let uiImage = UIImage(cgImage: cgImage)
        let finalImg = Image(uiImage: uiImage)
        return finalImg
    }
    
    @MainActor func setFilter (_ chosenFilter: CIFilter) {
        filter = chosenFilter
        loadImage()
        filterDialogShowing = false
        chosenFilterCount += 1
        
        currentFilterName = determineFilterName(chosenFilter.name)
        
        // if chosenFilterCount >= 100 {
            // requestReview()
        // }
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
