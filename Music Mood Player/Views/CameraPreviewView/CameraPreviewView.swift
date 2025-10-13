//
//  CameraPreviewView.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 14/10/2025.
//

import UIKit
import AVFoundation

final class CameraPreviewView<ViewModel: CameraPreviewViewModelProtocol>: UIView {

    let viewModel: ViewModel
    
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: viewModel.captureSession)
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    init(frame: CGRect = .zero, viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        self.layer.addSublayer(previewLayer)
        viewModel.previewInfo = .init(size: previewLayer.bounds.size, videoGravity: previewLayer.videoGravity)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        previewLayer.frame = bounds
        CATransaction.commit()
        viewModel.previewInfo = .init(size: previewLayer.bounds.size, videoGravity: previewLayer.videoGravity)
    }
}
