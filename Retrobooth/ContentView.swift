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
    @State private var selectedImages = [Image]()
    @State private var filterIntensity = 0.5
    @State private var pickerItems = [PhotosPickerItem]()
    @State private var filterDialogShowing = false
    
    @State var selectedUiImages: [UIImage] = []
    
    @AppStorage("chosenFilterCount") var chosenFilterCount = 0
    @Environment(\.requestReview) var requestReview
    
    @State private var filter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                PhotosPicker(selection: $pickerItems, maxSelectionCount: 10, matching: .images) {
                    if selectedImages.count > 0 {
                        ScrollView {
                            ForEach(0..<selectedImages.count, id: \.self) { i in
                                selectedImages[i]
                                    .resizable()
                                    .scaledToFit()
                                    .shadow(color: .black.opacity(0.4), radius: 8, x: 4, y: 4)
                            }
                        }
                        .padding(.horizontal, 8)
                        .scrollIndicators(.hidden)
                    } else {
                        VStack() {
                            Image("empty-folder")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(.blue)
                            
                            Text("No picture, press me.")
                                .font(.headline)
                            
                            Text("You can select up to 10 photos.")
                                .font(.footnote)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .multilineTextAlignment(.center)
                        
                    }
                }
                .buttonStyle(.plain)
                .onChange(of: pickerItems, loadImage)
                
                Spacer()
                
                VStack {
                    CustomButton(
                        title: "Change Filter",
                        alignment: .center,
                        backgroundColor: .primary,
                        action: changeFilter
                    )
                    
                    if selectedImages.count > 0 {
                        ShareLink(
                            items: selectedImages
                        ) { img in
                            SharePreview("Your beautiful image", image: img)
                        } label: {
                            CustomButtonLabel(
                                title: "Share",
                                alignment: .center,
                                backgroundColor: .blue,
                                isDisabled: false
                            )
                        }
                        .disabled(false)
                    } else {
                        CustomButtonLabel(
                            title: "Share",
                            alignment: .center,
                            backgroundColor: .blue,
                            isDisabled: true
                        )
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
                    
                    CustomButton(
                        title: "Caramel Fade",
                        description: "A cozy, cinematic blend: a touch of sepia, a whisper of blur, and a soft vignette.",
                        backgroundColor: .brown
                    ) {
                        setFilter(CIFilter.caramelFade())
                    }
                    
                    CustomButton(
                        title: "Arctic Mist",
                        description: "A crisp, cool look: daylight shift, teal hint, gentle vibrance, soft bloom, subtle vignette.",
                        backgroundColor: .blue
                    ) {
                        setFilter(CIFilter.arcticMist())
                    }
                    
                    Spacer()
                    
                    CustomButton(
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
            selectedImages.removeAll()
            
            for item in pickerItems {
                guard let imageData = try await item.loadTransferable(type: Data.self) else { return }
                guard let inputImage = UIImage(data: imageData) else { return }
                let beginImage = CIImage(image: inputImage)?
                    .oriented(forExifOrientation: exifOrientation(inputImage.imageOrientation))
                
                /// Core Image filters technically provide an `inputImage` property for assigning
                /// a `CIImage`, but this is often unreliable and may cause crashes. Instead,
                /// it’s safer to use `setValue(_:forKey:)` with the key `kCIInputImageKey`.
                filter.setValue(beginImage, forKey: kCIInputImageKey)
                
                if let processedImg = applyProcessing() {
                    selectedImages.append(processedImg)
                }
            }
        }
    }
    
    func applyProcessing() -> Image?  {
        guard let outputImage =  filter.outputImage else { return nil }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
        else { return nil }
        let uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage)
        return processedImage
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
