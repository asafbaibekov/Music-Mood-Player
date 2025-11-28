//
//  MoodHomeViewModel.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 21/09/2025.
//

import SwiftUI
import Combine

@MainActor
protocol MoodHomeViewModelProtocol: ObservableObject {
    
    var cameraViewModel: CameraPreviewViewModel { get }
    
    var isCameraHidden: Bool { get set }
    
    var isShowPlaylists: Bool { get set }
    
    var isDetecting: Bool { get set }
    
    var selectedMood: Mood? { get set }
    
    var facesPublisher: AnyPublisher<[UIImage], Never> { get }
    
    var moods: [Mood] { get }
    
    var musicStreamServices: [any MusicStreamService] { get }
}

@MainActor
final class MoodHomeViewModel: MoodHomeViewModelProtocol {
    
    let cameraViewModel = CameraPreviewViewModel()
    
    @Published var isCameraHidden: Bool = false
    
    @Published var isShowPlaylists: Bool = false
    
    @Published var isDetecting: Bool = false
    
    @Published var selectedMood: Mood? = nil
    
    var facesPublisher: AnyPublisher<[UIImage], Never> {
        self.faceExtractorService.facesPublisher(from: self.cameraViewModel.framePublisher)
    }
    
    private let faceExtractorService = FaceExtractorService()
    
    private var cancellables = Set<AnyCancellable>()
    
    let moods: [Mood] = [
        Mood(emoji: "😀", label: "Happy"),
        Mood(emoji: "😢", label: "Sad"),
        Mood(emoji: "😡", label: "Angry"),
        Mood(emoji: "😴", label: "Chill"),
        Mood(emoji: "🤩", label: "Excited"),
        Mood(emoji: "🤔", label: "Thoughtful")
    ]
    
    let musicStreamServices: [any MusicStreamService]
    
    init(musicStreamServices: [any MusicStreamService]) {
        self.musicStreamServices = musicStreamServices
        
        $selectedMood
            .sink(receiveValue: { [weak self]  in
                self?.isShowPlaylists = $0 != nil
            })
            .store(in: &cancellables)
        
        cameraViewModel
            .$cameraStatus
            .sink(receiveValue: { [weak self] cameraStatus in
                self?.isCameraHidden = cameraStatus != .running
            })
            .store(in: &cancellables)
    }
}
