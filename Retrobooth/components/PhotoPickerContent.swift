//
//  PhotoPickerContent.swift
//  Retrobooth
//
//  Created by Emir Arı on 28.08.2025.
//

import SwiftUI
import PhotosUI

struct PhotoPickerContent: View {
    let imageName: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    
    var body: some View {
        VStack(spacing: 6) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(.blue)
                .padding(.bottom, 6)
            
            Text(title)
                .font(.custom("FunnelDisplay-Medium", size: 20))
            
            Text(description)
                .font(.custom("FunnelDisplay-Light", size: 14))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
    }
}
