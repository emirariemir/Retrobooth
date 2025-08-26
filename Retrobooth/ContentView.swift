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
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var filterDialogShowing = false
    
    @AppStorage("chosenFilterCount") var chosenFilterCount = 0
    @Environment(\.requestReview) var requestReview
    
    @State private var filter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Click on the center to change image.")
                    .font(.footnote)
                
                Spacer()
                
                PhotosPicker(selection: $selectedPhoto) {
                    if let processedImage {
                        processedImage
                            .resizable()
                            .scaledToFit()
                            .shadow(color: .black.opacity(0.4), radius: 8, x: 4, y: 4)
                    } else {
                        ContentUnavailableView("No Picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
                    }
                }
                .buttonStyle(.plain)
                .onChange(of: selectedPhoto, loadImage)
                
                Spacer()
                
                HStack {
                    Button("Change filter", action: changeFilter)
                    
                    Spacer()
                    
                    if let processedImage {
                        ShareLink(item: processedImage, preview: SharePreview("Your beautiful image", image: processedImage))
                    }
                }
                
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Retrobooth")
            .sheet(isPresented: $filterDialogShowing) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Select a Filter")
                        .font(.title2)
                        .bold()
                    
                    FilterButton(
                        title: "Caramel Fade",
                        description: "A cozy, cinematic blend: a touch of sepia, a whisper of blur, and a soft vignette.",
                        backgroundColor: .brown
                    ) {
                        setFilter(CIFilter.caramelFade())
                    }
                    
                    FilterButton(
                        title: "Arctic Mist",
                        description: "A crisp, cool look: daylight shift, teal hint, gentle vibrance, soft bloom, subtle vignette.",
                        backgroundColor: .blue
                    ) {
                        setFilter(CIFilter.arcticMist())
                    }
                    
                    Spacer()
                    
                    FilterButton(
                        title: "Close",
                        alignment: .center,
                        backgroundColor: .red
                    ) {
                        filterDialogShowing = false
                    }
                }
                .presentationDetents([.medium])
                .padding()
            }
        }
    }
    
    func changeFilter() {
        filterDialogShowing = true
    }
    
    func loadImage() {
        Task {
            guard let imageData = try await selectedPhoto?.loadTransferable(type: Data.self) else { return }
            guard let inputImage = UIImage(data: imageData) else { return }
            
            let beginImage = CIImage(image: inputImage)?
                .oriented(forExifOrientation: exifOrientation(inputImage.imageOrientation))
            
            /// Core Image filters technically provide an `inputImage` property for assigning
            /// a `CIImage`, but this is often unreliable and may cause crashes. Instead,
            /// it’s safer to use `setValue(_:forKey:)` with the key `kCIInputImageKey`.
            filter.setValue(beginImage, forKey: kCIInputImageKey)
            
            applyProcessing()
        }
    }
    
    func applyProcessing() {
        let inputKeys = filter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            filter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            filter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            filter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey)
        }
        
        guard let outputImage =  filter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
        else { return }
        
        let uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage)
    }
    
    @MainActor func setFilter (_ chosenFilter: CIFilter) {
        filter = chosenFilter
        loadImage()
        
        filterDialogShowing = false
        
        chosenFilterCount += 1
        
        if chosenFilterCount >= 100 {
            requestReview()
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
