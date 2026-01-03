//
//  MoodHomeViewModel.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 21/09/2025.
//

import SwiftUI
import Combine

enum ContentState: Equatable {
    case noneLoggedIn
    case unselectedMood
    case showPlaylists(Mood)
    
    var isShowPlaylists: Bool {
        if case .showPlaylists = self {
            return true
        }
        return false
    }
}

@MainActor
protocol MoodHomeViewModelProtocol: ObservableObject {
    
    var cameraViewModel: CameraPreviewViewModel { get }
    
    var isCameraHidden: Bool { get set }
    
    var contentState: ContentState { get set }
    
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
    
    @Published var contentState: ContentState = .noneLoggedIn
    
    @Published var isDetecting: Bool = false
    
    @Published var selectedMood: Mood? = nil
    
    @Published private(set) var playlistCellViewModels = [any PlaylistCellViewModelProtocol]()
    
    var facesPublisher: AnyPublisher<[UIImage], Never> {
        self.faceExtractorService.facesPublisher(from: self.cameraViewModel.framePublisher)
    }
    
    private let faceExtractorService = FaceExtractorService()
    
    private var cancellables = Set<AnyCancellable>()
    
    let moods: [Mood] = Mood.allCases
    
    let musicStreamServices: [any MusicStreamService]
    
    init(musicStreamServices: [any MusicStreamService]) {
        self.musicStreamServices = musicStreamServices
        
        cameraViewModel
            .$cameraStatus
            .sink(receiveValue: { [weak self] cameraStatus in
                self?.isCameraHidden = cameraStatus != .running
            })
            .store(in: &cancellables)
        
        let isNoneLoggedInPublisher: AnyPublisher<Bool, Never> = musicStreamServices
            .map(\.isLoggedInPublisher)
            .reduce(Just([]).eraseToAnyPublisher()) { acc, next in
                acc.combineLatest(next, { $0 + [$1] }).eraseToAnyPublisher()
            }
            .map({ !$0.contains(true) })
            .eraseToAnyPublisher()
        
        isNoneLoggedInPublisher
            .combineLatest($selectedMood) { isNoneLoggedIn, mood -> ContentState in
                if isNoneLoggedIn {
                    return .noneLoggedIn
                } else if let mood {
                    return .showPlaylists(mood)
                }
                return .unselectedMood
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] contentState in
                self?.contentState = contentState
                guard case .showPlaylists = contentState else { return }
                self?.loadPlaylists()
            }
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
