//
//  SpotifyError.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 06/12/2025.
//

enum SpotifyError: Error, Codable, Equatable {
    case loginNeeded
    case expiredAccessToken
    case unknown(status: Int, message: String)

    private enum OuterKeys: String, CodingKey {
        case error
    }

    private enum InnerKeys: String, CodingKey {
        case status
        case message
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OuterKeys.self)
        let errorContainer = try container.nestedContainer(keyedBy: InnerKeys.self, forKey: .error)

        let status = try errorContainer.decode(Int.self, forKey: .status)
        let message = try errorContainer.decode(String.self, forKey: .message)

        switch message {
        case "No token provided", "Only valid bearer authentication supported":
            self = .loginNeeded
        case "The access token expired":
            self = .expiredAccessToken
        default:
            self = .unknown(status: status, message: message)
        }
    }
}
