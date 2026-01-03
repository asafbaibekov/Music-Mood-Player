//
//  YoutubeMusicRequestManager.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 31/12/2025.
//

import Foundation

final class YoutubeMusicRequestManager {
    
    let youtubeMusicAuthManager: YoutubeMusicAuthManager
    
    init(youtubeMusicAuthManager: YoutubeMusicAuthManager) {
        self.youtubeMusicAuthManager = youtubeMusicAuthManager
    }
    
    func performRequest(url: URL, params: [URLQueryItem]) async throws -> YoutubeMusicPlaylistsResponse {

        let accessToken = self.youtubeMusicAuthManager.accessToken

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = params
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        
        if let error = try? JSONDecoder().decode(YoutubeMusicError.self, from: data) {
            switch error {
            case .expiredAccessToken:
                throw YoutubeMusicError.expiredAccessToken
            case .loginNeeded:
                throw YoutubeMusicError.loginNeeded
            case .unknown(let status, let message):
                print("Youtube music error: \(status) – \(message)")
                throw URLError(.badServerResponse)
            }
        }
        return try JSONDecoder().decode(YoutubeMusicPlaylistsResponse.self, from: data)
    }
}
