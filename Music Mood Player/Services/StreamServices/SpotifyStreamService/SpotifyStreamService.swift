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
    
    var musicService: MusicService { .spotify }
    
    let isLoggedInPublisher: AnyPublisher<Bool, Never>
    
    private let spotifyAuthManager: SpotifyAuthManager
    
    private let spotifyRequestManager: SpotifyRequestManager
    
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
    
    func loadPlaylists() async throws -> [any PlaylistCellViewModelProtocol] {
        guard let response = try await loadNextPage() else { return [] }
        self.currentSpotifyPlaylistsResponse = response
        return self.currentSpotifyPlaylistsResponse?.items ?? []
    }
}

private extension SpotifyStreamService {
    
    func loadNextPage() async throws -> SpotifyPlaylistsResponse? {
        
        if let next = self.currentSpotifyPlaylistsResponse?.next {
            return try await self.spotifyRequestManager.performRequest(urlType: .url(next), params: [])
        } else if self.currentSpotifyPlaylistsResponse != nil {
            return nil
        }
        let params = [
            URLQueryItem(name: "q", value: "genre:\"rock\""),
            URLQueryItem(name: "type", value: "playlist"),
            URLQueryItem(name: "limit", value: "5")
        ]
        return try await self.spotifyRequestManager.performRequest(urlType: .endpoint(.search), params: params)
    }
}
