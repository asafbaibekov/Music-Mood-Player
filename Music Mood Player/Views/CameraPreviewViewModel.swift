//
//  CameraPreviewViewModel.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 13/10/2025.
//

import UIKit
import SwiftUI
import AVFoundation
import Combine

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

protocol CameraPreviewViewModelProtocol: ObservableObject {
    
    var previewInfo: CameraPreviewModels.PreviewLayerInfo? { get set }
    var cameraStatus: CameraPreviewModels.CameraStatus { get }
    var framePublisher: AnyPublisher<UIImage?, Never> { get }
    var captureSession: AVCaptureSession { get }

    func startSession()
    func stopSession()
}

final class CameraPreviewViewModel: NSObject, CameraPreviewViewModelProtocol {
    
    typealias CameraStatus = CameraPreviewModels.CameraStatus
    
    typealias CameraError = CameraPreviewModels.CameraError
    
    typealias PreviewLayerInfo = CameraPreviewModels.PreviewLayerInfo
    
    private let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    private var currentInput: AVCaptureDeviceInput?
    private let videoOutput = AVCaptureVideoDataOutput()
    private let frameSubject = PassthroughSubject<UIImage?, Never>()
    
    @Published private(set) var cameraStatus: CameraStatus = .idle
    
    let captureSession = AVCaptureSession()
    
    var previewInfo: PreviewLayerInfo?
    
    var framePublisher: AnyPublisher<UIImage?, Never> {
        frameSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    func startSession() {
        Task { @MainActor in
            self.cameraStatus = .starting
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            Task {
                if await AVCaptureDevice.requestAccess(for: .video) {
                    await start()
                } else {
                    Task { @MainActor in
                        cameraStatus = .noPermission
                    }
                }
            }
        case .authorized:
            Task { await start() }
        case .denied, .restricted:
            Task { @MainActor in
                cameraStatus = .noPermission
            }
        @unknown default:
            cameraStatus = .failed(CameraError.unknown)
        }
    }
    
    func stopSession() {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            guard self.captureSession.isRunning else { return }
            
            await MainActor.run {
                self.cameraStatus = .stopping
            }
            
            try? await Task.sleep(for: .milliseconds(450))
            
            self.captureSession.stopRunning()
            
            await MainActor.run {
                self.cameraStatus = .idle
            }
        }
    }

    private func configureSessionIfNeeded() {
        guard self.currentInput == nil else { return }
        self.captureSession.beginConfiguration()
        self.captureSession.sessionPreset = .high
        guard let captureDevice else {
            self.cameraStatus = .failed(CameraError.cameraNotAvailable)
            self.captureSession.commitConfiguration()
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if self.captureSession.canAddInput(input) {
                self.captureSession.addInput(input)
                self.currentInput = input
            } else {
                self.cameraStatus = .failed(CameraError.cannotAddInput)
            }
        } catch {
            self.cameraStatus = .failed(error)
        }
        
        let outputQueue = DispatchQueue(label: "CameraFrameQueue")
        videoOutput.setSampleBufferDelegate(self, queue: outputQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        if let connection = videoOutput.connection(with: .video), connection.isVideoRotationAngleSupported(90) {
            connection.videoRotationAngle = 90
            connection.isVideoMirrored = (captureDevice.position == .front)
        }
        
        self.captureSession.commitConfiguration()
    }
    
    private func start() async {
        configureSessionIfNeeded()
        
        guard !self.captureSession.isRunning else { return }
        
        await withCheckedContinuation { [weak self] continuation in
            Task.detached(priority: .userInitiated) { [weak self] in
                self?.captureSession.startRunning()
                continuation.resume()
            }
        }
        
        await MainActor.run {
            self.cameraStatus = .running
        }
    }

}

extension CameraPreviewViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let previewInfo else { return }

        var ciImage = CIImage(cvPixelBuffer: imageBuffer)

        ciImage = adjustImage(ciImage, to: previewInfo)

        guard let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) else { return }
        frameSubject.send(UIImage(cgImage: cgImage))
    }

    // Adjust image according to preview layer's aspect ratio and videoGravity
    private func adjustImage(_ image: CIImage, to previewInfo: PreviewLayerInfo) -> CIImage {
        let bufferAspectRatio = image.extent.width / image.extent.height
        let targetAspectRatio = previewInfo.size.width / previewInfo.size.height
        
        switch previewInfo.videoGravity {
        case .resize:
            // Stretched to fill the bounds, ignore aspect ratio
            let scaleX = targetAspectRatio / bufferAspectRatio
            return image.transformed(by: CGAffineTransform(scaleX: scaleX, y: 1))

        case .resizeAspect:
            // Fit entire frame — may add letterboxing
            let scale = (bufferAspectRatio > targetAspectRatio)
                ? targetAspectRatio / bufferAspectRatio // Image is wider — scale down width
                : bufferAspectRatio / targetAspectRatio // Image is taller — scale down height
            return image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            
        case .resizeAspectFill:
            // Crop center to fill bounds
            guard abs(targetAspectRatio - bufferAspectRatio) > 0.01 else { return image }
            var rect = image.extent
            if targetAspectRatio > bufferAspectRatio {
                // Preview is wider → crop vertically
                let newHeight = rect.width / targetAspectRatio
                rect.origin.y += (rect.height - newHeight) / 2
                rect.size.height = newHeight
            } else {
                // Preview is taller → crop horizontally
                let newWidth = rect.height * targetAspectRatio
                rect.origin.x += (rect.width - newWidth) / 2
                rect.size.width = newWidth
            }
            return image.cropped(to: rect)
        default:
            return image
        }
    }
}

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
