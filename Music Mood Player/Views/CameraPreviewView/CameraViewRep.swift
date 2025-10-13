//
//  CameraViewRep.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 14/10/2025.
//

import SwiftUI

struct CameraViewRep<ViewModel: CameraPreviewViewModelProtocol>: UIViewRepresentable {
    
    @Binding var isEnabled: Bool
    
    @ObservedObject var viewModel: ViewModel
    
    func makeUIView(context: Context) -> CameraPreviewView<ViewModel> {
        return CameraPreviewView(frame: .zero, viewModel: self.viewModel)
    }
    
    func updateUIView(_ uiView: CameraPreviewView<ViewModel>, context: Context) {
        if isEnabled, uiView.viewModel.cameraStatus == .idle {
            uiView.viewModel.startSession()
        } else if !isEnabled, uiView.viewModel.cameraStatus == .running {
            uiView.viewModel.stopSession()
        }
    }
}
