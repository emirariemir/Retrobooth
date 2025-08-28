//
//  CIFilter+RetroPixel.swift
//  Retrobooth
//
//  Created by Emir Arı on 27.08.2025.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation

extension CIFilter {

    /// A playful pixelation effect: blocky pixels, posterized colors, and a hint of vignette.
    @objc(CIRetroPixel) class RetroPixel: CIFilter {

        // KVC-compatible input
        @objc dynamic var inputImage: CIImage?

        // Tunables
        @objc dynamic var inputPixelScale: NSNumber = 18.0      // how big each pixel block is
        @objc dynamic var inputPosterizeLevels: NSNumber = 6.0  // fewer = more chunky colors
        @objc dynamic var inputVignetteIntensity: NSNumber = 0.4
        @objc dynamic var inputVignetteRadius: NSNumber = 1.5

        override var outputImage: CIImage? {
            guard let inputImage else { return nil }

            // 1) Pixelation
            let pixellate = CIFilter.pixellate()
            pixellate.inputImage = inputImage
            pixellate.scale = Float(truncating: inputPixelScale)

            // 2) Posterize for retro palette
            let posterize = CIFilter.colorPosterize()
            posterize.inputImage = pixellate.outputImage
            posterize.levels = Float(truncating: inputPosterizeLevels)

            // 3) Gentle vignette to guide focus
            let vignette = CIFilter.vignette()
            vignette.inputImage = posterize.outputImage
            vignette.intensity = Float(truncating: inputVignetteIntensity)
            vignette.radius = Float(truncating: inputVignetteRadius)

            return vignette.outputImage
        }
    }

    /// Convenience factory with defaults for fun "retro pixel art" look
    static func retroPixel(
        scale: Double = 18.0,
        posterizeLevels: Double = 6.0,
        vignetteIntensity: Double = 0.4,
        vignetteRadius: Double = 1.5
    ) -> CIFilter {
        let f = RetroPixel()
        f.setValue(scale as NSNumber, forKey: "inputPixelScale")
        f.setValue(posterizeLevels as NSNumber, forKey: "inputPosterizeLevels")
        f.setValue(vignetteIntensity as NSNumber, forKey: "inputVignetteIntensity")
        f.setValue(vignetteRadius as NSNumber, forKey: "inputVignetteRadius")
        return f
    }
}

