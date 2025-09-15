//
//  CIFilter+SilverGrit.swift
//  Retrobooth
//
//  Created by Emir Arı on 4.09.2025.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation

extension CIFilter {

    /// Monochrome, gritty film look: deep desaturation, mild contrast shaping, heavy soft grain, and a subtle vignette.
    /// Order: Desaturate/Contrast → Grain (overlay) → Vignette.
    @objc(CISilverGrit) class SilverGrit: CIFilter {

        // KVC-compatible so you can set with kCIInputImageKey externally
        @objc dynamic var inputImage: CIImage?

        // Tunables (NSNumber to stay KVC-friendly)
        /// 0…1 (1 = full desaturation)
        @objc dynamic var inputDesaturation: NSNumber = 1.0
        /// 0.5…1.5 (1 = neutral)
        @objc dynamic var inputContrast: NSNumber = 1.08
        /// -1…1 (negative darkens slightly, positive brightens)
        @objc dynamic var inputExposure: NSNumber = -0.05

        /// 0…1 (opacity of grain)
        @objc dynamic var inputGrainAmount: NSNumber = 0.28
        /// 0…10 (blur radius applied to grain to make it “chunkier”)
        @objc dynamic var inputGrainSoftness: NSNumber = 1.2
        /// 0.25…4.0 (scales the noise before blur; <1 = finer, >1 = coarser)
        @objc dynamic var inputGrainScale: NSNumber = 1.4

        /// 0…2
        @objc dynamic var inputVignetteIntensity: NSNumber = 0.6
        /// 0…5 (relative falloff)
        @objc dynamic var inputVignetteRadius: NSNumber = 2.0

        override var outputImage: CIImage? {
            guard let inputImage else { return nil }

            // 1) Desaturate + contrast + exposure shaping
            let color = CIFilter.colorControls()
            color.inputImage = inputImage
            // desaturation is inverted into a saturation value
            let desat = CGFloat(truncating: inputDesaturation).clamped(to: 0...1)
            color.saturation = Float(max(0, 1 - desat))
            color.contrast = Float(CGFloat(truncating: inputContrast))
            let baseColor = color.outputImage ?? inputImage

            let exposure = CIFilter.exposureAdjust()
            exposure.inputImage = baseColor
            exposure.ev = Float(CGFloat(truncating: inputExposure))
            let base = exposure.outputImage ?? baseColor

            // 2) Build monochrome grain from CIRandomGenerator
            // DO NOT "crop before blur". THIS GIVES PREVIEWS WHITE BORDER!!
            let rng = CIFilter.randomGenerator()

            let scale = CGFloat(truncating: inputGrainScale).clamped(to: 0.25...4)
            let scaledNoise = rng.outputImage?
                .transformed(by: CGAffineTransform(scaleX: scale, y: scale))

            // 2) Desaturate
            let mono = scaledNoise?
                .applyingFilter("CIColorControls", parameters: [
                    kCIInputSaturationKey: 0.0,
                    kCIInputContrastKey: 1.0
                ])

            // 3) Soften (BLUR) while the image still has infinite/clamped extent
            let softened = mono?
                .clampedToExtent()
                .applyingFilter("CIGaussianBlur", parameters: [
                    kCIInputRadiusKey: inputGrainSoftness
                ])

            let monoNoise = softened?
                .cropped(to: inputImage.extent)

            // Control grain opacity via alpha in a color matrix
            let noiseAlpha = CIFilter.colorMatrix()
            noiseAlpha.inputImage = monoNoise
            noiseAlpha.aVector = CIVector(x: 0, y: 0, z: 0, w: CGFloat(truncating: inputGrainAmount).clamped(to: 0...1))

            // Stronger, crisper grain than soft-light: use Overlay blend
            let overlay = CIFilter.overlayBlendMode()
            overlay.backgroundImage = base
            overlay.inputImage = noiseAlpha.outputImage
            let withGrain = overlay.outputImage ?? base

            // 3) Vignette to focus the frame
            let vignette = CIFilter.vignette()
            vignette.inputImage = withGrain
            vignette.intensity = Float(CGFloat(truncating: inputVignetteIntensity))
            vignette.radius = Float(CGFloat(truncating: inputVignetteRadius))

            return vignette.outputImage
        }
    }

    /// Convenience factory with sensible “gritty mono” defaults.
    static func silverGrit(
        desaturation: Double = 1.0,
        contrast: Double = 1.08,
        exposureEV: Double = -0.05,
        grainAmount: Double = 0.28,
        grainSoftness: Double = 1.2,
        grainScale: Double = 1.4,
        vignetteIntensity: Double = 0.6,
        vignetteRadius: Double = 2.0
    ) -> CIFilter {
        let f = SilverGrit()
        f.setValue(desaturation as NSNumber, forKey: "inputDesaturation")
        f.setValue(contrast as NSNumber, forKey: "inputContrast")
        f.setValue(exposureEV as NSNumber, forKey: "inputExposure")
        f.setValue(grainAmount as NSNumber, forKey: "inputGrainAmount")
        f.setValue(grainSoftness as NSNumber, forKey: "inputGrainSoftness")
        f.setValue(grainScale as NSNumber, forKey: "inputGrainScale")
        f.setValue(vignetteIntensity as NSNumber, forKey: "inputVignetteIntensity")
        f.setValue(vignetteRadius as NSNumber, forKey: "inputVignetteRadius")
        return f
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
