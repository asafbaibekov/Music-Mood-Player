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

final class SpotifyStreamService: NSObject, MusicStreamService {
    
    var name: String = "Spotify"
    
    var icon: ImageResource = Icons.Custom.spotify.imageResource
    
    let isLoggedInSubject = CurrentValueSubject<Bool, Never>(false)
    
    lazy var sptSessionManager: SPTSessionManager = {
        let configuration = SPTConfiguration(
            clientID: "2f4647040f594d49a3d0c8369090182c",
            redirectURL: URL(string: "musicmoodplayer://spotify-login-callback")!
        )
        return SPTSessionManager(configuration: configuration, delegate: self)
    }()
    
    func handleURL(spotifyURL url: URL) {
        let flag = sptSessionManager.application(UIApplication.shared, open: url, options: [:])
        print("\(#function) \(flag)")
    }
    
    func login() {
        let scopes: SPTScope = [.playlistReadCollaborative, .playlistReadPrivate, .appRemoteControl]
        self.sptSessionManager.initiateSession(with: scopes, options: .default, campaign: nil)
    }
    
    func logout() {
        self.isLoggedInSubject.value = false
        print("\(name) logged out")
    }
}

extension SpotifyStreamService: SPTSessionManagerDelegate {
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print(#function)
        self.isLoggedInSubject.value = true
        print("\(name) logged in")
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: any Error) {
        print(#function)
        self.isLoggedInSubject.value = false
    }
}
