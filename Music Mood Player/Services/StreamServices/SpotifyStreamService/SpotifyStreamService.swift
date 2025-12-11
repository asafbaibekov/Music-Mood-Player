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
    
    private var pendingContinuations = [CheckedContinuation<SpotifyPlaylistsResponse?, Error>]()
    
    private var isRenewing = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(sessionStorable: AnyStorable<SPTSession>) {
        self.spotifyAuthManager = SpotifyAuthManager(sessionStorable: sessionStorable)
        self.isLoggedInPublisher = self.spotifyAuthManager.isLoggedInPublisher
        
        self.spotifyAuthManager
            .renewSessionPublisher
            .sink(receiveValue: { [weak self] in
                self?.onRenewSession()
            })
            .store(in: &cancellables)
        
        self.spotifyAuthManager
            .authErrorPublisher
            .sink(receiveValue: { [weak self] _ in
                self?.pendingContinuations.removeAll()
                self?.isRenewing = false
            })
            .store(in: &cancellables)
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
            let spotifyPlaylistsResponse = try await self.spotifyAPIRequest(endpoint: .search, params: params)
            print("Rpotify Response", spotifyPlaylistsResponse.map({ "\($0)" }) ?? "nil")
            
            guard let playlistCellViewModels = spotifyPlaylistsResponse?.items
                .map({ item in
                    PlaylistCellViewModel(title: item.name ?? "", subtitle: item.itemDescription ?? "", imageURL: item.images?.first?.url)
                }) else { return }
            
            print("Spotify PlaylistCellViewModels", playlistCellViewModels)
        }
    }
}

private extension SpotifyStreamService {
    
    enum Endpoint: String {
        case search
    }
    
    func spotifyAPIRequest(endpoint: Endpoint, params: [URLQueryItem]) async throws -> SpotifyPlaylistsResponse? {
        
        let accessToken = self.spotifyAuthManager.accessToken
        
        var urlComponents = URLComponents(string: "https://api.spotify.com/v1/\(endpoint)")!
        urlComponents.queryItems = params
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        if let error = try? JSONDecoder().decode(SpotifyError.self, from: data) {
            switch error {
            case .expiredAccessToken:
                return try await withCheckedThrowingContinuation { continuation in
                    pendingContinuations.append(continuation)
                    guard !isRenewing else { return }
                    isRenewing = true
                    self.spotifyAuthManager.renewSession()
                }
            case .loginNeeded:
                throw URLError(.badServerResponse)
            case .unknown(let status, let message):
                print("Spotify error: \(status) – \(message)")
                throw URLError(.badServerResponse)
            }
        }
        
        return try JSONDecoder().decode(SpotifyPlaylistsResponse.self, from: data)
    }
    
    func onRenewSession() {
        let continuations = self.pendingContinuations
        self.pendingContinuations.removeAll()
        self.isRenewing = false

        Task {
            for continuation in continuations {
                do {
                    let result = try await self.spotifyAPIRequest(endpoint: .search, params: [])
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
