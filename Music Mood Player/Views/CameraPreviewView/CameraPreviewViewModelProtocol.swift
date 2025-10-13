//
//  CameraPreviewViewModelProtocol.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 14/10/2025.
//

import UIKit
import AVFoundation
import Combine

protocol CameraPreviewViewModelProtocol: ObservableObject {
    
    var previewInfo: CameraPreviewModels.PreviewLayerInfo? { get set }
    var cameraStatus: CameraPreviewModels.CameraStatus { get }
    var framePublisher: AnyPublisher<UIImage?, Never> { get }
    var captureSession: AVCaptureSession { get }

    func startSession()
    func stopSession()
}
