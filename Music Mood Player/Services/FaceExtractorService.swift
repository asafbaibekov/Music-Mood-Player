//
//  FaceExtractorService.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 14/10/2025.
//

import Foundation
import UIKit
import Vision
import Combine

struct FaceExtractorConfig {
    /// How often to process frames (helps CPU/GPU). 0.0 = every frame.
    var throttle: TimeInterval = 0.08
    /// Extra padding around the detected face (as a fraction of min(width,height)).
    var paddingFraction: CGFloat = 0
    /// Minimum face size as a fraction of the image min(width,height).
    var minFaceSizeFraction: CGFloat = 0.08
    /// Work queue for Vision & cropping.
    var workQueue = DispatchQueue(label: "FaceExtractorServiceQueue", qos: .userInitiated)
}

final class FaceExtractorService {
    
    private let config: FaceExtractorConfig
    
    init(config: FaceExtractorConfig = .init()) {
        self.config = config
    }
    
    func facesPublisher(from frames: AnyPublisher<UIImage?, Never>) -> AnyPublisher<[UIImage], Never> {
        frames
            .compactMap { $0 }
            .throttle(for: .seconds(config.throttle), scheduler: config.workQueue, latest: true)
            .flatMap { [weak self] image -> AnyPublisher<[UIImage], Never> in
                guard let self else { return Just([]).eraseToAnyPublisher() }
                return self.detectAndCropFaces(in: image)
                    .subscribe(on: self.config.workQueue)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

private extension FaceExtractorService {
    func detectAndCropFaces(in uiImage: UIImage) -> AnyPublisher<[UIImage], Never> {
        guard let cgImage = uiImage.cgImage else {
            return Just([]).eraseToAnyPublisher()
        }
        
        return Future<[UIImage], Never> { [config] promise in
            let request = VNDetectFaceRectanglesRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: CGImagePropertyOrientation(uiImage.imageOrientation), options: [:])
            
            guard (try? handler.perform([request])) != nil else {
                promise(.success([]))
                return
            }
            
            let results: [VNFaceObservation] = request.results ?? []

            // Convert normalized rects → pixel rects, filter by size, crop with padding
            let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
            let minSizePx = min(imageSize.width, imageSize.height) * config.minFaceSizeFraction
            
            let faces: [UIImage] = results
                .map { faceObservation in self.pixelRect(fromNormalized: faceObservation.boundingBox, imageSize: imageSize) }
                .filter { rectPx in rectPx.width >= minSizePx && rectPx.height >= minSizePx }
                .compactMap { rectPx in self.cropFace(from: cgImage, in: rectPx, paddingFraction: config.paddingFraction) }
            
            promise(.success(faces))
        }
        .eraseToAnyPublisher()
    }
    
    /// VN boundingBox is normalized in a bottom-left origin coordinate space.
    func pixelRect(fromNormalized bbox: CGRect, imageSize: CGSize) -> CGRect {
        let w = bbox.width * imageSize.width
        let h = bbox.height * imageSize.height
        let x = bbox.minX * imageSize.width
        // Flip Y because CoreGraphics origin is top-left while Vision’s is bottom-left
        let y = (1.0 - bbox.minY - bbox.height) * imageSize.height
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    func cropFace(from cgImage: CGImage, in rect: CGRect, paddingFraction: CGFloat) -> UIImage? {
        // Expand rect with padding and clamp to image bounds
        let minSide = min(rect.width, rect.height)
        let pad = minSide * paddingFraction
        var padded = rect.insetBy(dx: -pad, dy: -pad)
        
        // Make it square for consistent downstream models (optional but helpful)
        let side = max(padded.width, padded.height)
        padded.size = CGSize(width: side, height: side)
        padded.origin.x -= (side - rect.width) / 2.0 - pad
        padded.origin.y -= (side - rect.height) / 2.0 - pad
        
        let imgRect = CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height)
        padded = padded.intersection(imgRect)
        guard let crop = cgImage.cropping(to: padded) else { return nil }
        return UIImage(cgImage: crop, scale: 1.0, orientation: .up)
    }
}

private extension CGImagePropertyOrientation {
    
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default:
            self = .up
        }
    }
}
