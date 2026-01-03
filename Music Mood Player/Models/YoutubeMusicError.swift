//
//  YoutubeMusicError.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 31/12/2025.
//

enum YoutubeMusicError: Error, Codable, Equatable {
    case loginNeeded
    case expiredAccessToken
    case unknown(status: String, message: String)

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

        let status = try errorContainer.decode(String.self, forKey: .status)
        let message = try errorContainer.decode(String.self, forKey: .message)

        switch status {
        case "PERMISSION_DENIED":
            self = .loginNeeded
        case "UNAUTHENTICATED":
            self = .expiredAccessToken
        default:
            self = .unknown(status: status, message: message)
        }
    }
}
