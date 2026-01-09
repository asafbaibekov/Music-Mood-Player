//
//  YouTubeMusicStreamService.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 27/11/2025.
//

import Foundation
import SwiftUI
import Combine
import GoogleSignIn

final class YouTubeMusicStreamService: MusicStreamService {
    
    var musicService: MusicService { .youtubeMusic }
    
    let isLoggedInPublisher: AnyPublisher<Bool, Never>
    
    private let youtubeMusicAuthManager = YoutubeMusicAuthManager()
    private let youtubeMusicRequestManager: YoutubeMusicRequestManager
    private var currentResponse: YoutubeMusicPlaylistsResponse?
    private var seenPlaylistIds = Set<String>()
    
    init() {
        self.isLoggedInPublisher = youtubeMusicAuthManager.isLoggedInPublisher
        self.youtubeMusicRequestManager = YoutubeMusicRequestManager(youtubeMusicAuthManager: youtubeMusicAuthManager)
    }
    
    func handleURL(googleURL url: URL) {
        self.youtubeMusicAuthManager.handleURL(googleURL: url)
    }
    
    func login() {
        self.youtubeMusicAuthManager.login()
    }
    
    func logout() {
        self.youtubeMusicAuthManager.logout()
    }
    
    func loadPlaylists() async throws -> [any PlaylistCellViewModelProtocol] {
        guard let response = try await loadNextPage() else { return [] }
        self.currentResponse = response
        return response.items.filter { item in
            if seenPlaylistIds.contains(item.id) {
                return false
            }
            seenPlaylistIds.insert(item.id)
            return true
        }
    }
}

private extension YouTubeMusicStreamService {
    
    func loadNextPage() async throws -> YoutubeMusicPlaylistsResponse? {
        
        var params = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "type", value: "playlist"),
            URLQueryItem(name: "maxResults", value: "5"),
            URLQueryItem(name: "order", value: "date"),
            URLQueryItem(name: "safeSearch", value: "moderate"),
            URLQueryItem(name: "q", value: "sad")
        ]
        
        if let nextPageToken = currentResponse?.nextPageToken {
            params.append(URLQueryItem(name: "pageToken", value: nextPageToken))
        } else if currentResponse != nil {
            return nil
        }
        let url = URL(string: "https://www.googleapis.com/youtube/v3/search")!
        return try await self.youtubeMusicRequestManager.performRequest(url: url, params: params)
    }
}
