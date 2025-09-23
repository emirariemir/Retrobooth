//
//  CIFilter+PatinaGrain.swift
//  Retrobooth
//
//  Created by Emir Arı on 27.08.2025.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation

extension CIFilter {

    /// A cool-leaning vintage vibe: lighter sepia, gentle cool shift, soft grain, and a deeper vignette.
    /// Order: Sepia → Temperature/Tint (cooler) → Grain (soft-light) → Vignette.
    @objc(CIPatinaGrain) class PatinaGrain: CIFilter {

        // KVC-compatible so you can set with kCIInputImageKey externally
        @objc dynamic var inputImage: CIImage?

        // Tunables (NSNumber to stay KVC-friendly)
        @objc dynamic var inputSepiaIntensity: NSNumber = 0.35        // less warm than Caramel
        @objc dynamic var inputCoolTemperature: NSNumber = 5200        // target neutral temp (≈6500 is neutral; lower = cooler)
        @objc dynamic var inputNoiseAmount: NSNumber = 0.12            // grain opacity (0...1)
        @objc dynamic var inputNoiseSoftness: NSNumber = 0.6           // blur radius applied to grain
        @objc dynamic var inputVignetteIntensity: NSNumber = 0.85      // stronger vignette
        @objc dynamic var inputVignetteRadius: NSNumber = 2.3          // a bit wider falloff

        override var outputImage: CIImage? {
            guard let inputImage else { return nil }

            // 1) Subtle sepia
            let sepia = CIFilter.sepiaTone()
            sepia.inputImage = inputImage
            sepia.intensity = Float(truncating: inputSepiaIntensity)

            // 2) Cool shift (Temperature & Tint)
            let temp = CIFilter.temperatureAndTint()
            temp.inputImage = sepia.outputImage
            temp.neutral = CIVector(x: 6500, y: 0)
            temp.targetNeutral = CIVector(x: CGFloat(truncating: inputCoolTemperature), y: 0)
            let base = temp.outputImage ?? inputImage

            // 3) Soft monochrome grain (RNG -> desaturate -> CLAMP -> blur -> CROP)
            let rng = CIFilter.randomGenerator()
            let noisePre = rng.outputImage?
                .applyingFilter("CIColorControls", parameters: [
                    kCIInputSaturationKey: 0.0,
                    kCIInputContrastKey: 1.0
                ])
                .clampedToExtent()
                .applyingFilter("CIGaussianBlur", parameters: [
                    kCIInputRadiusKey: inputNoiseSoftness
                ])
            let noise = noisePre?.cropped(to: inputImage.extent)

            // Set grain opacity
            let noiseAlpha = CIFilter.colorMatrix()
            noiseAlpha.inputImage = noise
            noiseAlpha.aVector = CIVector(x: 0, y: 0, z: 0,
                                          w: CGFloat(truncating: inputNoiseAmount))

            // Soft-light blend for natural grain
            let softLight = CIFilter.softLightBlendMode()
            softLight.backgroundImage = base
            softLight.inputImage = noiseAlpha.outputImage
            let withGrain = softLight.outputImage ?? base

            // 4) Vignette
            let vignette = CIFilter.vignette()
            vignette.inputImage = withGrain
            vignette.intensity = Float(truncating: inputVignetteIntensity)
            vignette.radius = Float(truncating: inputVignetteRadius)
            let vimg = vignette.outputImage ?? withGrain

            // Preventing any residual fringe in thumbnails
            let forceOpaque = CIFilter.colorMatrix()
            forceOpaque.inputImage = vimg
            forceOpaque.aVector = CIVector(x: 0, y: 0, z: 0, w: 0) // ignore incoming alpha
            forceOpaque.biasVector = CIVector(x: 0, y: 0, z: 0, w: 1)

            // Return with integral extent to avoid fractional-edge artifacts
            return forceOpaque.outputImage?.cropped(to: inputImage.extent.integral)
        }
    }

    /// Convenience factory with sensible “vintage” defaults.
    static func patinaGrain(
        sepia: Double = 0.35,
        targetNeutralTemperature: Double = 5200,
        noiseAmount: Double = 0.12,
        noiseSoftness: Double = 0.6,
        vignetteIntensity: Double = 0.85,
        vignetteRadius: Double = 2.3
    ) -> CIFilter {
        let f = PatinaGrain()
        f.setValue(sepia as NSNumber, forKey: "inputSepiaIntensity")
        f.setValue(targetNeutralTemperature as NSNumber, forKey: "inputCoolTemperature")
        f.setValue(noiseAmount as NSNumber, forKey: "inputNoiseAmount")
        f.setValue(noiseSoftness as NSNumber, forKey: "inputNoiseSoftness")
        f.setValue(vignetteIntensity as NSNumber, forKey: "inputVignetteIntensity")
        f.setValue(vignetteRadius as NSNumber, forKey: "inputVignetteRadius")
        return f
    }
}

