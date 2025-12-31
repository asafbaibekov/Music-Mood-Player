//
//  MusicMoodPlayerApp.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 21/09/2025.
//

import SwiftUI

@main
struct MusicMoodPlayerApp: App {
    
    let spotifyService: SpotifyStreamService
    let youtubeMusicSerivce: YouTubeMusicStreamService
    
    let viewModel: MoodHomeViewModel
    
    init() {
        self.spotifyService = SpotifyStreamService(sessionStorable: SpotifySessionStorable().eraseToAnyStorable())
        self.youtubeMusicSerivce = YouTubeMusicStreamService()
        self.viewModel = MoodHomeViewModel(musicStreamServices: [
            spotifyService,
            youtubeMusicSerivce
        ])
    }
    
    var body: some Scene {
        WindowGroup {
            MoodHomeView(viewModel: viewModel)
                .onOpenURL(perform: onOpenURL(_:))
        }
    }
}

private extension MusicMoodPlayerApp {
    
    func onOpenURL(_ url: URL) {
        switch url.host() {
        case "spotify-login-callback":
            spotifyService.handleURL(spotifyURL: url)
        default:
            youtubeMusicSerivce.handleURL(googleURL: url)
        }
    }
}
