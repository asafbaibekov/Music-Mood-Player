//
//  CameraPreviewModels.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 14/10/2025.
//

import AVFoundation

enum CameraPreviewModels {
    
    enum CameraStatus: Equatable {
        case idle
        case starting
        case running
        case stopping
        case failed(Error)
        case noPermission
        
        static func == (lhs: CameraStatus, rhs: CameraStatus) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.running, .running), (.noPermission, .noPermission):
                return true
            case let (.failed(lhsError), .failed(rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    
    enum CameraError: Error {
        case cameraNotAvailable
        case cannotAddInput
        case unknown
    }
    
    struct PreviewLayerInfo {
        let size: CGSize
        let videoGravity: AVLayerVideoGravity
    }
}
