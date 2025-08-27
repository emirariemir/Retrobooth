//
//  CustomPhotoPickerContent.swift
//  Retrobooth
//
//  Created by Emir Arı on 27.08.2025.
//

import SwiftUI
import PhotosUI

struct CustomPhotoPickerContent: View {
    let imageName: String
    let title: String
    let description: String
    
    var body: some View {
        VStack() {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(.blue)
            
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.footnote)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
    }
}
