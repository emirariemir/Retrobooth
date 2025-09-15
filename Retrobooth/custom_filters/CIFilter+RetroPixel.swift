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

            let extent = inputImage.extent.integral

            // 1) Pixelation (CLAMP before, CROP after)
            let clamped = inputImage.clampedToExtent()

            let pixellate = CIFilter.pixellate()
            pixellate.inputImage = clamped
            pixellate.scale = Float(truncating: inputPixelScale)

            // 1.2) align the pixel grid so edge tiles aren’t partial
            let s = max(1, CGFloat(truncating: inputPixelScale))
            let center = CGPoint(x: (extent.midX / s).rounded() * s,
                                 y: (extent.midY / s).rounded() * s)
            pixellate.center = center

            let pix = pixellate.outputImage?.cropped(to: extent) ?? inputImage

            // 2) Posterize
            let posterize = CIFilter.colorPosterize()
            posterize.inputImage = pix
            posterize.levels = Float(truncating: inputPosterizeLevels)
            let post = posterize.outputImage ?? pix

            // 3) Vignette (doesn’t change extent)
            let vignette = CIFilter.vignette()
            vignette.inputImage = post
            vignette.intensity = Float(truncating: inputVignetteIntensity)
            vignette.radius = Float(truncating: inputVignetteRadius)

            // Final crop to integral extent
            return (vignette.outputImage ?? post).cropped(to: extent)
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

