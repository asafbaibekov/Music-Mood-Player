//
//  SpotifyRequestManager.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 12/12/2025.
//

import Foundation
import Combine

final class SpotifyRequestManager {
    
    enum Endpoint: String {
        case search
    }
    
    private struct PendingRequest {
        let continuation: CheckedContinuation<SpotifyPlaylistsResponse?, Error>
        let urlType: URLType
        let params: [URLQueryItem]
    }
    
    enum URLType {
        case url(URL?)
        case endpoint(Endpoint)
    }
    
    private var pendingRequests = [PendingRequest]()
    
    private var isRenewing = false

    private let spotifyAuthManager: SpotifyAuthManager

    private var cancellables = Set<AnyCancellable>()
    
    init(spotifyAuthManager: SpotifyAuthManager) {
        self.spotifyAuthManager = spotifyAuthManager
        
        self.spotifyAuthManager
            .renewSessionPublisher
            .sink(receiveValue: { [weak self] in
                self?.onRenewSession()
            })
            .store(in: &cancellables)
        
        self.spotifyAuthManager
            .authErrorPublisher
            .sink(receiveValue: { [weak self] _ in
                self?.onAuthError()
            })
            .store(in: &cancellables)
    }
    
    func performRequest(urlType: URLType, params: [URLQueryItem]) async throws -> SpotifyPlaylistsResponse? {

        let accessToken = self.spotifyAuthManager.accessToken

        let url: URL? = {
            switch urlType {
            case .url(let url):
                return url
            case .endpoint(let endpoint):
                var components = URLComponents(string: "https://api.spotify.com/v1/\(endpoint)")!
                components.queryItems = params
                return components.url
            }
        }()
        
        guard let url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)

        if let error = try? JSONDecoder().decode(SpotifyError.self, from: data) {
            switch error {
            case .expiredAccessToken:
                return try await withCheckedThrowingContinuation { continuation in
                    pendingRequests.append(PendingRequest(continuation: continuation, urlType: urlType, params: params))
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
}

private extension SpotifyRequestManager {
    
    func onRenewSession() {
        let pendingRequests = self.pendingRequests
        self.pendingRequests.removeAll()
        self.isRenewing = false

        Task {
            for pendingRequest in pendingRequests {
                do {
                    let result: SpotifyPlaylistsResponse? = try await self.performRequest(urlType: pendingRequest.urlType, params: pendingRequest.params)
                    pendingRequest.continuation.resume(returning: result)
                } catch {
                    pendingRequest.continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func onAuthError() {
        self.pendingRequests.removeAll()
        self.isRenewing = false
    }
}
