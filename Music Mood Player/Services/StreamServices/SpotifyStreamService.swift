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
    
    let sessionStorable: AnyStorable<SPTSession>
    
    lazy var sptSessionManager: SPTSessionManager = {
        let configuration = SPTConfiguration(
            clientID: "2f4647040f594d49a3d0c8369090182c",
            redirectURL: URL(string: "musicmoodplayer://spotify-login-callback")!
        )
        configuration.tokenSwapURL = URL(string: "https://u3irfuz4i3lbxzrux24zytjw7m0dwzva.lambda-url.eu-west-1.on.aws/")!
        configuration.tokenRefreshURL = URL(string: "https://c7x2hf5hzrpsqvzw5int2t65pa0ncjgz.lambda-url.eu-west-1.on.aws/")!
        return SPTSessionManager(configuration: configuration, delegate: self)
    }()
    
    private var pendingRequests = [() async throws -> Void]()
    
    private var isRenewing = false
    
    init(sessionStorable: AnyStorable<SPTSession>) {
        self.sessionStorable = sessionStorable
        super.init()
        if let session = try? sessionStorable.load(), self.sptSessionManager.session == nil {
            self.sptSessionManager.session = session
            self.isLoggedInSubject.value = true
        } else if self.sptSessionManager.session != nil {
            self.isLoggedInSubject.value = true
        }
    }
    
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
        self.sptSessionManager.session = nil
        try? self.sessionStorable.delete()
    }
    
    func loadPlaylists() {
        Task {
            let params = [
                URLQueryItem(name: "q", value: "genre:\"rock\""),
                URLQueryItem(name: "type", value: "playlist"),
                URLQueryItem(name: "limit", value: "20")
            ]
            try await self.spotifyAPIRequest(endpoint: .search, params: params)
        }
    }
}

private extension SpotifyStreamService {
    
    enum Endpoint: String {
        case search
    }
    
    func spotifyAPIRequest(endpoint: Endpoint, params: [URLQueryItem]) async throws {
        
        let accessToken = self.sptSessionManager.session?.accessToken ?? ""
        
        guard var urlComponents = URLComponents(string: "https://api.spotify.com/v1/\(endpoint)") else { return }
        urlComponents.queryItems = params
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        if let error = try? JSONDecoder().decode(SpotifyError.self, from: data) {
            switch error {
            case .expiredAccessToken:
                pendingRequests.append({ [weak self] in
                    try await self?.spotifyAPIRequest(endpoint: endpoint, params: params)
                })
                if !isRenewing {
                    isRenewing = true
                    sptSessionManager.renewSession()
                }
                break
            case .loginNeeded:
                break
            case .unknown(let status, let message):
                print("Spotify error: \(status) – \(message)")
            }
            return
        }
        
        let dataString = String(data: data, encoding: .utf8) ?? "No data"
        print("dataString", dataString)
    }
}

extension SpotifyStreamService: SPTSessionManagerDelegate {
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        self.isLoggedInSubject.value = true
        try? self.sessionStorable.save(session)
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: any Error) {
        self.isLoggedInSubject.value = false
        self.pendingRequests.removeAll()
        self.isRenewing = false
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        self.isLoggedInSubject.value = true
        try? self.sessionStorable.save(session)
        
        let requests = self.pendingRequests
        self.pendingRequests.removeAll()
        self.isRenewing = false

        Task {
            for req in requests {
                try? await req()
            }
        }
    }
}
