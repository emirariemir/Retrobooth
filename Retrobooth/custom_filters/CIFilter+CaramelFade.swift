//
//  CIFilter+CaramelFade.swift
//  Retrobooth
//
//  Created by Emir Arı on 26.08.2025.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation

extension CIFilter {
    
    /// A cozy, cinematic blend: a touch of sepia, a whisper of blur, and a soft vignette.
    @objc(CICaramelFade) class CaramelFade: CIFilter {
        
        // KVC-compatible so you can set with kCIInputImageKey
        @objc dynamic var inputImage: CIImage?
        
        // Tunables (NSNumber to stay KVC-friendly)
        @objc dynamic var inputSepiaIntensity: NSNumber = 0.55  // "a little" sepia
        @objc dynamic var inputBlurRadius: NSNumber = 0.8       // very light blur
        @objc dynamic var inputVignetteIntensity: NSNumber = 0.45
        @objc dynamic var inputVignetteRadius: NSNumber = 1.8
        
        override var outputImage: CIImage? {
            guard let inputImage else { return nil }
            
            // 1) Sepia
            let sepia = CIFilter.sepiaTone()
            sepia.inputImage = inputImage
            sepia.intensity = Float(truncating: inputSepiaIntensity)
            
            // 2) Clamp before blur to avoid edge transparency, then blur lightly
            let clamp = CIFilter.affineClamp()
            clamp.inputImage = sepia.outputImage
            clamp.transform = .identity
            
            let blur = CIFilter.gaussianBlur()
            blur.inputImage = clamp.outputImage
            blur.radius = Float(truncating: inputBlurRadius)
            
            // 3) Vignette on the blurred result, then crop back to original extent
            let vignette = CIFilter.vignette()
            vignette.inputImage = blur.outputImage?.cropped(to: inputImage.extent)
            vignette.intensity = Float(truncating: inputVignetteIntensity)
            vignette.radius = Float(truncating: inputVignetteRadius)
            
            return vignette.outputImage
        }
    }
    
    /// Convenience factory with sensible “subtle” defaults
    static func caramelFade(
        sepia: Double = 0.55,
        blur: Double = 0.8,
        vignetteIntensity: Double = 0.45,
        vignetteRadius: Double = 1.8
    ) -> CIFilter {
        let f = CaramelFade()
        f.setValue(sepia as NSNumber, forKey: "inputSepiaIntensity")
        f.setValue(blur as NSNumber, forKey: "inputBlurRadius")
        f.setValue(vignetteIntensity as NSNumber, forKey: "inputVignetteIntensity")
        f.setValue(vignetteRadius as NSNumber, forKey: "inputVignetteRadius")
        return f
    }
}
