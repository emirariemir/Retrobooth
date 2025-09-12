//
//  FilterSelectorButton.swift
//  Retrobooth
//
//  Created by Emir Arı on 28.08.2025.
//

import SwiftUI

struct FilterSelectorButton: View {
    var filterName: String
    var action: () -> Void
    var isDisabled: Bool
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading) {
                    Text("Selected filter:")
                        .font(.custom("FunnelDisplay-Light", size: 14))
                        .foregroundStyle(.white)
                        .opacity(0.7)
                    Text(filterName)
                        .font(.custom("FunnelDisplay-Medium", size: 20))
                        .foregroundStyle(.white)
                }
                
                Image(systemName: "chevron.up")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(isDisabled ? 0.5 : 1)
            .disabled(isDisabled)
        }
    }
}
