//
//  CIFilter+ArcticMist.swift
//  Retrobooth
//
//  Created by Emir Arı on 26.08.2025.
//

import CoreImage
import CoreImage.CIFilterBuiltins

extension CIFilter {

    /// A crisp, cool look: daylight shift, teal hint, gentle vibrance, soft bloom, subtle vignette.
    @objc(CIArcticMist) class ArcticMist: CIFilter {

        // KVC-friendly input
        @objc dynamic var inputImage: CIImage?

        // Tunables (NSNumber for KVC)
        /// 0...1 scale for how cool the temperature & hue shift should be.
        @objc dynamic var inputCoolAmount: NSNumber = 0.6
        /// Vibrance amount (-1...1), subtle boost by default.
        @objc dynamic var inputVibrance: NSNumber = 0.25
        /// Bloom radius/intensity for a cool glow.
        @objc dynamic var inputBloomRadius: NSNumber = 8.0
        @objc dynamic var inputBloomIntensity: NSNumber = 0.2
        /// Vignette finishing touch.
        @objc dynamic var inputVignetteIntensity: NSNumber = 0.35
        @objc dynamic var inputVignetteRadius: NSNumber = 1.6

        override var outputImage: CIImage? {
            guard let inputImage else { return nil }

            let cool = Float(truncating: inputCoolAmount)
            let vibr = Float(truncating: inputVibrance)
            let bloomR = Float(truncating: inputBloomRadius)
            let bloomI = Float(truncating: inputBloomIntensity)
            let vignI  = Float(truncating: inputVignetteIntensity)
            let vignR  = Float(truncating: inputVignetteRadius)

            // 1) Cool temperature (toward 8000K) with a neutral baseline around D65 (6500K)
            let temperature = CIFilter.temperatureAndTint()
            temperature.inputImage = inputImage
            // Blend from 6500K to ~8000K based on cool amount
            let targetK: CGFloat = 6500 + CGFloat(cool) * (8000 - 6500)
            temperature.neutral = CIVector(x: 6500, y: 0)
            temperature.targetNeutral = CIVector(x: targetK, y: 0)

            // 2) Tiny hue shift toward teal (-12°) scaled by cool amount
            let hue = CIFilter.hueAdjust()
            hue.inputImage = temperature.outputImage
            hue.angle = (-12.0 * .pi / 180.0) * cool  // radians

            // 3) Gentle vibrance to keep colors lively after the cool shift
            let vibrance = CIFilter.vibrance()
            vibrance.inputImage = hue.outputImage
            vibrance.amount = vibr

            // 4) Clamp to avoid edge transparency before bloom
            let clamp = CIFilter.affineClamp()
            clamp.inputImage = vibrance.outputImage
            clamp.transform = .identity

            // 5) Soft bloom for a clean, icy glow
            let bloom = CIFilter.bloom()
            bloom.inputImage = clamp.outputImage
            bloom.radius = bloomR
            bloom.intensity = bloomI

            // 6) Subtle vignette; crop back to original extent
            let vignette = CIFilter.vignette()
            vignette.inputImage = bloom.outputImage?.cropped(to: inputImage.extent)
            vignette.intensity = vignI
            vignette.radius = vignR

            return vignette.outputImage
        }
    }

    /// Convenience factory for Arctic Mist
    static func arcticMist(
        coolAmount: Double = 0.6,
        vibrance: Double = 0.25,
        bloomRadius: Double = 8.0,
        bloomIntensity: Double = 0.2,
        vignetteIntensity: Double = 0.35,
        vignetteRadius: Double = 1.6
    ) -> CIFilter {
        let f = ArcticMist()
        f.setValue(coolAmount as NSNumber,        forKey: "inputCoolAmount")
        f.setValue(vibrance as NSNumber,          forKey: "inputVibrance")
        f.setValue(bloomRadius as NSNumber,       forKey: "inputBloomRadius")
        f.setValue(bloomIntensity as NSNumber,    forKey: "inputBloomIntensity")
        f.setValue(vignetteIntensity as NSNumber, forKey: "inputVignetteIntensity")
        f.setValue(vignetteRadius as NSNumber,    forKey: "inputVignetteRadius")
        return f
    }
}

