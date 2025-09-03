//
//  PermissionSheet.swift
//  Retrobooth
//
//  Created by Emir Arı on 2.09.2025.
//

import SwiftUI
import PhotosUI

// Keeping an enum for future permissions
enum Permission: String, CaseIterable {
    case camera = "Camera Access"
    case photoLibrary = "Photo Library Access"
    
    var isPermitted: Bool? {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        return status == .notDetermined ? nil : status == .authorized || status == .limited
    }
    
    var orderedIndex: Int {
        switch self {
        case .camera: 0
        case .photoLibrary: 1
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
                VStack (alignment: .leading) {
                    Text("Required Permissions")
                        .font(.custom("FunnelDisplay-Medium", size: 24))
                    
                    Spacer()
                    
                    VStack (alignment: .leading, spacing: 15) {
                        ForEach(states) { state in
                                PermissionItem(state)
                        }
                    }
                    
                    Spacer()
                    
                    CustomButton(title: thereIsAnyRejection ? "Go to settings" : "Continue", alignment: .center, backgroundColor: .primary, isDisabled: !allPermissionsGranted && !thereIsAnyRejection) {
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
                .presentationDetents([.height(250)])
                .interactiveDismissDisabled()
                .onChange(of: currentIndex) { oldValue, newValue in
                    guard states[newValue].isPermitted == nil else { return }
                    requestPermission(newValue)
                }
            }
            .onAppear {
                showSheet = !allPermissionsGranted
                if let firstRequest = states.firstIndex(where: {$0.isPermitted == nil}) {
                    requestPermission(firstRequest)
                }
            }
    }
    
    @ViewBuilder
    private func PermissionItem(_ state: PermissionState) -> some View {
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
            
            Text(state.id.rawValue)
                .font(.custom("FunnelDisplay-Light", size: 16))
        }
    }
    
    private func requestPermission(_ index: Int) {
        Task { @MainActor in
            let permission = states[index].id
            switch permission {
            // TODO: Add camera access here!
            case .camera:
                let status = await AVCaptureDevice.requestAccess(for: .video)
                states[index].isPermitted = status
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
    }
}

#Preview {
    ContentView()
}
