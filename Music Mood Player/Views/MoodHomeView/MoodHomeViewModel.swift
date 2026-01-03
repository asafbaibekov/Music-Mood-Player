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
    
    var playlistCellViewModels: [any PlaylistCellViewModelProtocol] { get }
    
    var facesPublisher: AnyPublisher<[UIImage], Never> { get }
    
    var moods: [Mood] { get }
    
    var musicStreamServices: [any MusicStreamService] { get }
    
    func loadPlaylists()
}

@MainActor
final class MoodHomeViewModel: MoodHomeViewModelProtocol {
    
    let cameraViewModel = CameraPreviewViewModel()
    
    @Published var isCameraHidden: Bool = false
    
    @Published var isShowPlaylists: Bool = false
    
    @Published var isDetecting: Bool = false
    
    @Published var selectedMood: Mood? = nil
    
    @Published private(set) var playlistCellViewModels = [any PlaylistCellViewModelProtocol]()
    
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
            .handleEvents(receiveOutput: { [weak self] in
                self?.isShowPlaylists = $0 != nil
            })
            .compactMap({ $0 })
            .sink(receiveValue: { [weak self] _ in
                self?.loadPlaylists()
            })
            .store(in: &cancellables)
        
        cameraViewModel
            .$cameraStatus
            .sink(receiveValue: { [weak self] cameraStatus in
                self?.isCameraHidden = cameraStatus != .running
            })
            .store(in: &cancellables)
    }
    
    func loadPlaylists() {
        Task { [weak self] in
            let viewModels = await self?.loadPlaylists()
            await MainActor.run { [weak self] in
                self?.playlistCellViewModels += viewModels?.shuffled() ?? []
            }
        }
    }
}

private extension MoodHomeViewModel {
    
    func loadPlaylists() async -> [any PlaylistCellViewModelProtocol] {
        let results = await withTaskGroup(of: Result<[any PlaylistCellViewModelProtocol], Error>.self) { [weak self] group in
            guard let self else { return [Result<[any PlaylistCellViewModelProtocol], Error>]() }
            for service in self.musicStreamServices {
                group.addTask {
                    return await Result {
                        try await service.loadPlaylists()
                    }
                }
            }
            
            var results = [Result<[any PlaylistCellViewModelProtocol], Error>]()
            for await result in group {
                results.append(result)
            }
            return results
        }
        
        let viewModels = results
            .compactMap { try? $0.get() }
            .flatMap { $0 }
        
        return viewModels
    }
}
