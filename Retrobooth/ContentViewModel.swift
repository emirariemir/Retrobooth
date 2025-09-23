//
//  ContentViewModel.swift
//  Retrobooth
//
//  Created by Emir Arı on 18.09.2025.
//

import SwiftUI
import PhotosUI

// MARK: - Filters
enum FilterKind: CaseIterable, @MainActor Identifiable {
    case caramelFade, arcticMist, polarRadiance, patinaGrain, silverGrit, retroPixel
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .caramelFade: "Caramel Fade"
        case .arcticMist: "Arctic Mist"
        case .polarRadiance: "Polar Radiance"
        case .patinaGrain: "Patina Grain"
        case .silverGrit: "Silver Grit"
        case .retroPixel: "Retro Pixel"
        }
    }
    
    var ciName: String {
        switch self {
        case .caramelFade: "CICaramelFade"
        case .arcticMist: "CIArcticMist"
        case .polarRadiance: "CIPolarRadiance"
        case .patinaGrain: "CIPatinaGrain"
        case .silverGrit: "CISilverGrit"
        case .retroPixel: "CIRetroPixel"
        }
    }
    
    var cardFilterName: String {
        switch self {
        case .caramelFade: "caramelFade"
        case .arcticMist: "arcticMist"
        case .polarRadiance: "polarRadiance"
        case .patinaGrain: "patinaGrain"
        case .silverGrit: "silverGrit"
        case .retroPixel: "retroPixel"
        }
    }

    var description: LocalizedStringKey {
        switch self {
        case .caramelFade:
            "A cozy, cinematic blend: a touch of sepia, a whisper of blur, and a soft vignette."
        case .arcticMist:
            "Daylight shift, teal hint, gentle vibrance, soft bloom, subtle vignette."
        case .polarRadiance:
            "Brighter, icier look: stronger cool shift, white-point bias, clean bloom, crisp edges."
        case .patinaGrain:
            "Cool-leaning vintage: lighter sepia, gentle cool shift, soft film grain, deeper vignette."
        case .silverGrit:
            "Monochrome grit: deep desaturation, crisp contrast, heavy film grain, subtle vignette."
        case .retroPixel:
            "Playful pixelation with posterized colors and a hint of vignette for retro readability."
        }
    }
    
    func makeFilter() -> CIFilter { CIFilter(name: ciName) ?? CIFilter.colorControls() }
}

// MARK: - Chosen Photo Blueprint
struct PhotoItem: Identifiable, Equatable {
    let id = UUID()
    var original: CIImage
    var processed: CGImage?
    var appliedFilter: FilterKind
}

// MARK: - App Review Throttler
@MainActor
final class AppReviewManager {
    static let shared = AppReviewManager()
    private let keyLastPrompt = "review.lastPrompt"
    private let minDaysBetweenPrompts: Double = 30
    
    func canPrompt(now: Date = .now) -> Bool {
        let last = UserDefaults.standard.object(forKey: keyLastPrompt) as? Date ?? .distantPast
        return now.timeIntervalSince(last) > minDaysBetweenPrompts*24*3600
    }
    
    func recordPrompt(now: Date = .now) { UserDefaults.standard.set(now, forKey: keyLastPrompt) }
}

// MARK: - Toast
struct Toast: Identifiable { let id = UUID(); let text: String }
struct ToastView: View {
    let toast: Toast
    var onDismiss: () -> Void
    @State private var visible = false
    var body: some View {
        VStack {
            Spacer()
            Text(toast.text)
                .font(.subheadline)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(.ultraThinMaterial, in: Capsule())
                .shadow(radius: 6)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.2)) { visible = true }
                    Task { try? await Task.sleep(nanoseconds: 2_000_000_000); withAnimation { visible = false }; try? await Task.sleep(nanoseconds: 300_000_000); onDismiss() }
                }
                .opacity(visible ? 1 : 0)
                .padding(.bottom, 24)
        }
        .transition(.move(edge: .bottom))
        .animation(.snappy, value: visible)
    }
}

// MARK: - Utilities
@MainActor
final class CIHelper {
    static let shared = CIHelper()
    let context: CIContext
    let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!
    
    private init() {
        context = CIContext(options: [
            .workingColorSpace: sRGB,
            .outputColorSpace: sRGB
        ])
    }
    
    func render(_ ci: CIImage) -> CGImage? {
        context.createCGImage(ci, from: ci.extent)
    }
    
    func exif(_ o: UIImage.Orientation) -> Int32 {
        switch o {
        case .up: 1
        case .down: 3
        case .left: 8
        case .right: 6
        case .upMirrored: 2
        case .downMirrored: 4
        case .leftMirrored: 5
        case .rightMirrored: 7
        @unknown default: 1
        }
    }
    
    func downscaled(_ ci: CIImage, targetWidth: CGFloat) -> CIImage {
        guard ci.extent.width > targetWidth else { return ci }
        let scale = targetWidth / ci.extent.width
        return ci.applyingFilter("CILanczosScaleTransform", parameters: [
            kCIInputScaleKey: scale,
            kCIInputAspectRatioKey: 1.0
        ])
    }
}

// MARK: - Loading Overlay
struct LoadingOverlay: View {
    var text: String
    var body: some View {
        Color.black.opacity(0.25).ignoresSafeArea()
        VStack(spacing: 12) {
            ProgressView().progressViewStyle(.circular)
            Text(text).font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(radius: 12)
        .accessibilityAddTraits(.isModal)
    }
}

// MARK: - View Model
@MainActor
final class ContentVM: ObservableObject {
    @Published var items: [PhotoItem] = []
    @Published var currentIndex: Int = 0
    @Published var isProcessing = false
    @Published var toast: Toast? = nil
    
    @AppStorage("chosenFilterCount") var chosenFilterCount = 0
    
    private var loadTask: Task<Void, Never>? = nil
    
    func load(pickerItems: [PhotosPickerItem], targetWidth: CGFloat) {
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else { return }
            await MainActor.run { self.isProcessing = true; self.items.removeAll(); self.currentIndex = 0 }
            defer { Task { @MainActor in self.isProcessing = false } }
            
            for p in pickerItems {
                if Task.isCancelled { return }
                do {
                    guard let data = try await p.loadTransferable(type: Data.self),
                          let ui = UIImage(data: data)
                    else { continue }
                    
                    let oriented = CIImage(image: ui)?.oriented(forExifOrientation: CIHelper.shared.exif(ui.imageOrientation)) ?? CIImage()
                    let scaled = CIHelper.shared.downscaled(oriented, targetWidth: targetWidth)
                    
                    var item = PhotoItem(original: scaled, processed: nil, appliedFilter: .caramelFade)
                    item.processed = render(ci: scaled, with: item.appliedFilter)
                    await MainActor.run { self.items.append(item) }
                } catch {
                    await MainActor.run { self.toast = .init(text: "Failed to load an image.") }
                }
            }
        }
    }
    
    func apply(_ kind: FilterKind) {
        guard items.indices.contains(currentIndex) else { return }
        items[currentIndex].appliedFilter = kind
        items[currentIndex].processed = render(ci: items[currentIndex].original, with: kind)
    }
    
    
    func currentUIImage() -> UIImage? {
        guard items.indices.contains(currentIndex), let cg = items[currentIndex].processed else { return nil }
        return UIImage(cgImage: cg)
    }
    
    
    private func render(ci: CIImage, with kind: FilterKind) -> CGImage? {
        let f = kind.makeFilter()
        f.setValue(ci, forKey: kCIInputImageKey)
        guard let out = f.outputImage else { return nil }
        return CIHelper.shared.render(out)
    }
}
