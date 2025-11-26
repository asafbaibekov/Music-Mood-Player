//
//  MusicServices.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 26/11/2025.
//

import Foundation
import SwiftUI
import Combine

final class SpotifyService: MusicStreamService {
    
    var name: String = "Spotify"
    
    var icon: ImageResource = Icons.Custom.spotify.imageResource
    
    let isLoggedInSubject = CurrentValueSubject<Bool, Never>(false)
    
    func login() {
        self.isLoggedInSubject.value = true
        print("\(name) logged in")
    }
    
    func logout() {
        self.isLoggedInSubject.value = false
        print("\(name) logged out")
    }
}

final class AppleMusicService: MusicStreamService {
    
    var name: String = "Apple Music"
    
    var icon: ImageResource = Icons.Custom.apple_music.imageResource
    
    let isLoggedInSubject = CurrentValueSubject<Bool, Never>(false)
    
    func login() {
        self.isLoggedInSubject.value = true
        print("\(name) logged in")
    }
    
    func logout() {
        self.isLoggedInSubject.value = false
        print("\(name) logged out")
    }
}

final class YouTubeMusicService: MusicStreamService {
    
    var name: String = "Youtube Music"
    
    var icon: ImageResource = Icons.Custom.youtube_music.imageResource
    
    let isLoggedInSubject = CurrentValueSubject<Bool, Never>(false)
    
    func login() {
        self.isLoggedInSubject.value = true
        print("\(name) logged in")
    }
    
    func logout() {
        self.isLoggedInSubject.value = false
        print("\(name) logged out")
    }
}

