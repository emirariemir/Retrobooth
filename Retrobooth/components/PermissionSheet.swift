//
//  PermissionSheet.swift
//  Retrobooth
//
//  Created by Emir Arı on 2.09.2025.
//

import SwiftUI
import PhotosUI

// Keeping an enum for future permissions
// such as `case camera = "Camera Access"`
enum Permission: String, CaseIterable {
    case photoLibrary = "Tap to allow access to your Photo Library"
    
    var isPermitted: Bool? {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        return status == .notDetermined ? nil : status == .authorized || status == .limited
    }
    
    var orderedIndex: Int {
        switch self {
        case .photoLibrary: 0
        }
    }
}

extension View {
    @ViewBuilder
    func permissionSheet(_ permissions: [Permission]) -> some View {
        self
            .modifier(PermissionSheetViewModifier(permissions: permissions))
    }
}

fileprivate struct PermissionSheetViewModifier: ViewModifier {
    init(permissions: [Permission]) {
        let initialStates = permissions.sorted(by: {
            $0.orderedIndex < $1.orderedIndex
        }).compactMap {
            PermissionState(id: $0)
        }
        
        self._states = .init(initialValue: initialStates)
    }
    
    @State private var showSheet: Bool = false
    @State private var states: [PermissionState]
    @State private var currentIndex: Int = 0
    
    @Environment(\.openURL) var openUrl
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showSheet) {
                VStack (alignment: .leading, spacing: 10) {
                    Text("Photo Access Needed")
                        .font(.custom("FunnelDisplay-Medium", size: 24))
                    
                    Text("We just need access to your photo library so you can save and edit your pictures. That’s it — nothing else.")
                        .font(.custom("FunnelDisplay-Light", size: 15))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    VStack (alignment: .leading, spacing: 15) {
                        ForEach(states) { state in
                            PermissionItem(state) {
                                requestPermission(0)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    CustomButton(title: thereIsAnyRejection ? "Open Settings" : "Continue", alignment: .center, backgroundColor: .primary, isDisabled: !allPermissionsGranted && !thereIsAnyRejection) {
                        if thereIsAnyRejection {
                            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                openUrl(settingsUrl)
                            }
                        } else {
                            showSheet = false
                        }
                    }
                }
                .padding()
                .presentationDetents([.height(300)])
                .interactiveDismissDisabled()
            }
            .onAppear {
                showSheet = !allPermissionsGranted
            }
    }
    
    @ViewBuilder
    private func PermissionItem(_ state: PermissionState, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .stroke(.gray, lineWidth: 1)
                    Group {
                        if let permitted = state.isPermitted {
                            Image(systemName: permitted ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(permitted ? .green : .red)
                        } else {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundStyle(.gray)
                        }
                    }
                    .font(.title3)
                    .transition(.symbolEffect)
                }
                .frame(width: 22, height: 22)
                
                Text(LocalizedStringKey(state.id.rawValue))
                    .font(.custom("FunnelDisplay-Light", size: 16))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func requestPermission(_ index: Int) {
        Task { @MainActor in
            let permission = states[index].id
            switch permission {
            // TODO: Add camera access here in future (if needed)!
            case .photoLibrary:
                let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
                states[index].isPermitted = status == .authorized || status == .limited
            }
            
            currentIndex = min(currentIndex + 1, states.count - 1)
        }
    }
    
    private var allPermissionsGranted: Bool {
        states.filter({
            if let isPermitted = $0.isPermitted {
                return isPermitted
            }
            
            return false
        }).count == states.count
    }
    
    private var thereIsAnyRejection: Bool {
        states.contains(where: {$0.isPermitted == false})
    }
    
    private struct PermissionState: Identifiable {
        var id: Permission
        var isPermitted: Bool?
        
        init(id: Permission) {
            self.id = id
            self.isPermitted = id.isPermitted
        }
    }
}

#Preview {
    ContentView()
}
