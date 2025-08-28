//
//  CIFilter+PolarRadiance.swift
//  Retrobooth
//
//  Created by Emir Arı on 27.08.2025.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation

extension CIFilter {

    /// A punchier, brighter cool look: deeper cool shift, icy white point, clean bloom, and crisp edges.
    /// Order: Temperature → Hue (teal) → Vibrance → White Point → Exposure → Bloom → Sharpen → (subtle) Vignette.
    @objc(CIPolarRadiance) class PolarRadiance: CIFilter {

        // KVC-friendly input
        @objc dynamic var inputImage: CIImage?

        // Tunables (NSNumber for KVC)
        /// 0...1: how strong the cool transformation should be (temp & hue).
        @objc dynamic var inputCoolAmount: NSNumber = 0.8
        /// Vibrance amount (-1...1)
        @objc dynamic var inputVibrance: NSNumber = 0.35
        /// Extra brightness via exposure (EV)
        @objc dynamic var inputExposureEV: NSNumber = 0.25
        /// Bloom glow
        @objc dynamic var inputBloomRadius: NSNumber = 12.0
        @objc dynamic var inputBloomIntensity: NSNumber = 0.35
        /// Light edge crispness after bloom
        @objc dynamic var inputSharpen: NSNumber = 0.3
        /// Subtle vignette to keep focus (still bright)
        @objc dynamic var inputVignetteIntensity: NSNumber = 0.2
        @objc dynamic var inputVignetteRadius: NSNumber = 2.0
        /// How much to bias whites toward a cool tint (0...0.1 is reasonable)
        @objc dynamic var inputWhitePointShift: NSNumber = 0.02

        override var outputImage: CIImage? {
            guard let inputImage else { return nil }

            let cool     = Float(truncating: inputCoolAmount)
            let vibr     = Float(truncating: inputVibrance)
            let ev       = Float(truncating: inputExposureEV)
            let bloomR   = Float(truncating: inputBloomRadius)
            let bloomI   = Float(truncating: inputBloomIntensity)
            let sharpen  = Float(truncating: inputSharpen)
            let vignI    = Float(truncating: inputVignetteIntensity)
            let vignR    = Float(truncating: inputVignetteRadius)
            let wpShift  = CGFloat(truncating: inputWhitePointShift)

            // 1) Cooler temperature: blend 6500K → ~9000K by cool amount
            let temperature = CIFilter.temperatureAndTint()
            temperature.inputImage = inputImage
            let targetK: CGFloat = 6500 + CGFloat(cool) * (9000 - 6500)
            temperature.neutral = CIVector(x: 6500, y: 0)
            temperature.targetNeutral = CIVector(x: targetK, y: 0)

            // 2) Small hue shift toward teal (~ -14° scaled by cool amount)
            let hue = CIFilter.hueAdjust()
            hue.inputImage = temperature.outputImage
            hue.angle = (-14.0 * .pi / 180.0) * cool

            // 3) Vibrance to keep colors lively after cooling
            let vibrance = CIFilter.vibrance()
            vibrance.inputImage = hue.outputImage
            vibrance.amount = vibr

            // 4) Icy white point bias (very subtle cyan tint in highlights)
            let whitePoint = CIFilter.whitePointAdjust()
            whitePoint.inputImage = vibrance.outputImage
            // Slightly cooler than pure white
            whitePoint.color = CIColor(red: 1.0 - wpShift*0.5, green: 1.0, blue: 1.0 + wpShift)

            // 5) Brighten overall exposure
            let exposure = CIFilter.exposureAdjust()
            exposure.inputImage = whitePoint.outputImage
            exposure.ev = ev

            // 6) Clamp before bloom to avoid edge transparency
            let clamp = CIFilter.affineClamp()
            clamp.inputImage = exposure.outputImage
            clamp.transform = .identity

            // 7) Clean, cool bloom
            let bloom = CIFilter.bloom()
            bloom.inputImage = clamp.outputImage
            bloom.radius = bloomR
            bloom.intensity = bloomI

            // 8) Recover edge clarity (light sharpen), then crop back
            let sharpenLuma = CIFilter.sharpenLuminance()
            sharpenLuma.inputImage = bloom.outputImage?.cropped(to: inputImage.extent)
            sharpenLuma.sharpness = sharpen

            // 9) Very subtle vignette (keep overall bright feel)
            let vignette = CIFilter.vignette()
            vignette.inputImage = sharpenLuma.outputImage
            vignette.intensity = vignI
            vignette.radius = vignR

            return vignette.outputImage
        }
    }

    /// Convenience factory
    static func polarRadiance(
        coolAmount: Double = 0.8,
        vibrance: Double = 0.35,
        exposureEV: Double = 0.25,
        bloomRadius: Double = 12.0,
        bloomIntensity: Double = 0.35,
        sharpen: Double = 0.3,
        vignetteIntensity: Double = 0.2,
        vignetteRadius: Double = 2.0,
        whitePointShift: Double = 0.02
    ) -> CIFilter {
        let f = PolarRadiance()
        f.setValue(coolAmount as NSNumber,        forKey: "inputCoolAmount")
        f.setValue(vibrance as NSNumber,          forKey: "inputVibrance")
        f.setValue(exposureEV as NSNumber,        forKey: "inputExposureEV")
        f.setValue(bloomRadius as NSNumber,       forKey: "inputBloomRadius")
        f.setValue(bloomIntensity as NSNumber,    forKey: "inputBloomIntensity")
        f.setValue(sharpen as NSNumber,           forKey: "inputSharpen")
        f.setValue(vignetteIntensity as NSNumber, forKey: "inputVignetteIntensity")
        f.setValue(vignetteRadius as NSNumber,    forKey: "inputVignetteRadius")
        f.setValue(whitePointShift as NSNumber,   forKey: "inputWhitePointShift")
        return f
    }
}

