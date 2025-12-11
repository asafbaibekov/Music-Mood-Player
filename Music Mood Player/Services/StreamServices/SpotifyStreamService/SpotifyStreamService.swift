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
    
    private let spotifyAuthManager: SpotifyAuthManager
    
    private let spotifyRequestManager: SpotifyRequestManager
    
    private var isRenewing = false
    
    private var cancellables = Set<AnyCancellable>()
    
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
            let params = [
                URLQueryItem(name: "q", value: "genre:\"rock\""),
                URLQueryItem(name: "type", value: "playlist"),
                URLQueryItem(name: "limit", value: "20")
            ]
            let spotifyPlaylistsResponse = try await self.spotifyRequestManager.performRequest(endpoint: .search, params: params)
            
            print("Rpotify Response", spotifyPlaylistsResponse.map({ "\($0)" }) ?? "nil")
            
            guard let playlistCellViewModels = spotifyPlaylistsResponse?.items
                .map({ item in
                    PlaylistCellViewModel(title: item.name ?? "", subtitle: item.itemDescription ?? "", imageURL: item.images?.first?.url)
                }) else { return }
            
            print("Spotify PlaylistCellViewModels", playlistCellViewModels)
        }
    }
}
