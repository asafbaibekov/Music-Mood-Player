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
    
    init() {
        self.isLoggedInPublisher = youtubeMusicAuthManager.isLoggedInPublisher
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
        return []
    }
}
