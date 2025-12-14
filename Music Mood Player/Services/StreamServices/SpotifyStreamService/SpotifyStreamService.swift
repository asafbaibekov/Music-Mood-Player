//
//  SpotifyStreamService.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 27/11/2025.
//

import Foundation
import SwiftUI
import Combine
import SpotifyiOS
import UIKit

final class SpotifyStreamService: MusicStreamService {
    
    var name: String = "Spotify"
    
    var icon: ImageResource = Icons.Custom.spotify.imageResource
    
    let isLoggedInPublisher: AnyPublisher<Bool, Never>
    
    private(set) lazy var playlistsStream: AnyPublisher<[any PlaylistCellViewModelProtocol], Never> = {
        self.playlistsPassthroughSubject.eraseToAnyPublisher()
    }()
    
    private let spotifyAuthManager: SpotifyAuthManager
    
    private let spotifyRequestManager: SpotifyRequestManager
    
    private let playlistsPassthroughSubject = PassthroughSubject<[any PlaylistCellViewModelProtocol], Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    private var currentSpotifyPlaylistsResponse: SpotifyPlaylistsResponse?
    
    init(sessionStorable: AnyStorable<SPTSession>) {
        self.spotifyAuthManager = SpotifyAuthManager(sessionStorable: sessionStorable)
        self.isLoggedInPublisher = self.spotifyAuthManager.isLoggedInPublisher
        self.spotifyRequestManager = SpotifyRequestManager(spotifyAuthManager: spotifyAuthManager)
    }
    
    func handleURL(spotifyURL url: URL) {
        self.spotifyAuthManager.handleURL(spotifyURL: url)
    }
    
    func login() {
        self.spotifyAuthManager.login()
    }
    
    func logout() {
        self.spotifyAuthManager.logout()
    }
    
    func loadPlaylists() {
        Task {
            self.currentSpotifyPlaylistsResponse = try await loadNextPage()
            
            guard let playlistCellViewModels = self.currentSpotifyPlaylistsResponse?.items
                .map({ item in
                    PlaylistCellViewModel(title: item.name ?? "", subtitle: item.itemDescription ?? "", imageURL: item.images?.first?.url)
                }) else { return }
            
            self.playlistsPassthroughSubject.send(playlistCellViewModels)
        }
    }
}

private extension SpotifyStreamService {
    
    func loadNextPage() async throws -> SpotifyPlaylistsResponse? {
        
        if let currentResponse = self.currentSpotifyPlaylistsResponse {
            let next = currentResponse.next
            return try await self.spotifyRequestManager.performRequest(urlType: .url(next), params: [])
        } else {
            let params = [
                URLQueryItem(name: "q", value: "genre:\"rock\""),
                URLQueryItem(name: "type", value: "playlist"),
                URLQueryItem(name: "limit", value: "5")
            ]
            return try await self.spotifyRequestManager.performRequest(urlType: .endpoint(.search), params: params)
        }
    }
}
