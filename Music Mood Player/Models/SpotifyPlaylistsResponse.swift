//
//  SpotifyPlaylistsResponse.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 06/12/2025.
//

import Foundation

struct SpotifyPlaylistsResponse: Codable, CustomStringConvertible {
    
    let limit: Int?
    let total: Int?
    let offset: Int?
    
    let href: URL?
    let next: URL?
    let previous: URL?
    
    let items: [SpotifyItem]
    
    var description: String { autoDescription() }
    
    enum CodingKeys: String, CodingKey {
        case playlists
    }

    enum PlaylistsKeys: String, CodingKey {
        case limit, total, offset, href, next, previous, items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let playlists = try container.nestedContainer(keyedBy: PlaylistsKeys.self, forKey: .playlists)

        self.limit = try playlists.decodeIfPresent(Int.self, forKey: .limit)
        self.total = try playlists.decodeIfPresent(Int.self, forKey: .total)
        self.offset = try playlists.decodeIfPresent(Int.self, forKey: .offset)
        
        self.href = try playlists.decodeIfPresent(URL.self, forKey: .href)
        self.next = try playlists.decodeIfPresent(URL.self, forKey: .next)
        self.previous = try playlists.decodeIfPresent(URL.self, forKey: .previous)
        
        self.items = (try playlists.decodeIfPresent([SpotifyItem?].self, forKey: .items) ?? []).compactMap({ $0 })
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var playlists = container.nestedContainer(keyedBy: PlaylistsKeys.self, forKey: .playlists)

        try playlists.encodeIfPresent(href, forKey: .href)
        try playlists.encodeIfPresent(limit, forKey: .limit)
        try playlists.encodeIfPresent(next, forKey: .next)
        try playlists.encodeIfPresent(offset, forKey: .offset)
        try playlists.encodeIfPresent(previous, forKey: .previous)
        try playlists.encodeIfPresent(total, forKey: .total)
        try playlists.encodeIfPresent(items, forKey: .items)
    }
}
