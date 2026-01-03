//
//  YoutubeMusicItem.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 31/12/2025.
//

import Foundation
import SwiftUI

struct YoutubeMusicItem: Decodable, CustomStringConvertible, Identifiable, Equatable {
    
    let id: String
    let name: String
    let itemDescription: String
    let channelID: String
    let channelTitle: String
    let thumbnails: Thumbnails
    let publishTime: Date?
    let publishedAt: Date?

    var description: String { autoDescription() }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let snippetContainer = try container.nestedContainer(keyedBy: SnippetKeys.self, forKey: .snippet)
        self.name            = try snippetContainer.decode(String.self, forKey: .name)
        self.itemDescription = try snippetContainer.decode(String.self, forKey: .description)
        self.channelID       = try snippetContainer.decode(String.self, forKey: .channelID)
        self.channelTitle    = try snippetContainer.decode(String.self, forKey: .channelTitle)
        self.thumbnails      = try snippetContainer.decode(Thumbnails.self, forKey: .thumbnails)
        self.publishTime     = try snippetContainer.decodeIfPresent(String.self, forKey: .publishTime).flatMap(ISO8601DateFormatter().date)
        self.publishedAt     = try snippetContainer.decodeIfPresent(String.self, forKey: .publishedAt).flatMap(ISO8601DateFormatter().date)
        
        let idContainer = try container.nestedContainer(keyedBy: IDKeys.self, forKey: .id)
        self.id = try idContainer.decode(String.self, forKey: .playlistId)
    }
}

extension YoutubeMusicItem {
    
    struct Thumbnails: Codable, CustomStringConvertible, Equatable {
        let thumbnailsDefault: Image?
        let medium: Image?
        let high: Image?

        var description: String { autoDescription() }

        enum CodingKeys: String, CodingKey {
            case thumbnailsDefault = "default"
            case medium
            case high
        }

        struct Image: Codable, CustomStringConvertible, Equatable {
            let url: URL
            let width: Int
            let height: Int
            
            var description: String { autoDescription() }
        }
    }
}

private extension YoutubeMusicItem {
    
    enum CodingKeys: String, CodingKey {
        case id
        case snippet
    }

    enum IDKeys: String, CodingKey {
        case playlistId
    }
    
    enum SnippetKeys: String, CodingKey {
        case thumbnails
        case channelID = "channelId"
        case name = "title"
        case description
        case channelTitle
        case publishTime
        case publishedAt
    }
}

extension YoutubeMusicItem: PlaylistCellViewModelProtocol {
    
    var title: String? {
        self.name
    }
    
    var subtitle: String? {
        self.itemDescription
    }
    
    var imageURL: URL? {
        (thumbnails.high ?? thumbnails.medium ?? thumbnails.thumbnailsDefault)?.url
    }
    
    var icon: ImageResource {
        MusicService.youtubeMusic.imageResource
    }
}
