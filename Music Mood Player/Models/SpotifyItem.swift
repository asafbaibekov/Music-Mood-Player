//
//  SpotifyItem.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 08/12/2025.
//

import Foundation

struct SpotifyItem: Codable, CustomStringConvertible {
    
    let id: String?
    let name: String?
    let itemDescription: String?
    let type: String?
    
    let images: [Image]?
    let itemPublic: Bool?
    let tracks: Tracks?
    
    let href: URL?
    let spotify: URL?
    
    var description: String { autoDescription() }
    
    enum ItemCodingKeys: String, CodingKey {
        case id, name
        case itemDescription = "description"
        case images
        case itemPublic = "public"
        case tracks, type
        case href
        case externalUrls = "external_urls"
    }
    
    enum ExternalUrlsKeys: String, CodingKey {
        case spotify
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ItemCodingKeys.self)

        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.itemDescription = try container.decodeIfPresent(String.self, forKey: .itemDescription)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        
        self.images = try container.decodeIfPresent([Image].self, forKey: .images)
        self.itemPublic = try container.decodeIfPresent(Bool.self, forKey: .itemPublic)
        self.tracks = try container.decodeIfPresent(Tracks.self, forKey: .tracks)
        
        self.href = try container.decodeIfPresent(URL.self, forKey: .href)
        self.spotify = {
            guard let external = try? container.nestedContainer(keyedBy: ExternalUrlsKeys.self, forKey: .externalUrls) else { return nil }
            return try? external.decodeIfPresent(URL.self, forKey: .spotify)
        }()
    }
    
    init(id: String?, name: String?, itemDescription: String?, images: [Image]?, itemPublic: Bool?, tracks: Tracks?, type: String?, href: URL?, spotify: URL?) {
        self.id = id
        self.name = name
        self.itemDescription = itemDescription
        self.images = images
        self.itemPublic = itemPublic
        self.tracks = tracks
        self.type = type
        self.href = href
        self.spotify = spotify
    }
    
    struct Image: Codable, CustomStringConvertible {
        let url: URL?
        let height: Int?
        let width: Int?
        
        var description: String { autoDescription() }
    }
    
    struct Tracks: Codable, CustomStringConvertible {
        let href: URL?
        let total: Int?
        
        var description: String { autoDescription() }
    }
    
    static var example: SpotifyItem {
        SpotifyItem(
            id: "3lRvb9RIb0MyUTU4O0IZAv",
            name: "BEST GUITAR SOLOS OF ALL TIME",
            itemDescription: "(Sub)genres include: metal, rock, pop, jazz, funk and many, many more... \\M&#x2F;",
            images: [
                Image(
                    url: URL(string: "https://mosaic.scdn.co/640/ab67616d00001e0217dd812df38fed44d6d2036eab67616d00001e024637341b9f507521afa9a778ab67616d00001e02e3f9acd031d98fcd2e9c802bab67616d00001e02e44963b8bb127552ac761873"),
                    height: 640,
                    width: 640
                ),
                Image(
                    url: URL(string: "https://mosaic.scdn.co/300/ab67616d00001e0217dd812df38fed44d6d2036eab67616d00001e024637341b9f507521afa9a778ab67616d00001e02e3f9acd031d98fcd2e9c802bab67616d00001e02e44963b8bb127552ac761873"),
                    height: 300,
                    width: 300
                ),
                Image(
                    url: URL(string: "https://mosaic.scdn.co/60/ab67616d00001e0217dd812df38fed44d6d2036eab67616d00001e024637341b9f507521afa9a778ab67616d00001e02e3f9acd031d98fcd2e9c802bab67616d00001e02e44963b8bb127552ac761873"),
                    height: 60,
                    width: 60
                )
            ],
            itemPublic: true,
            tracks: Tracks(
                href: URL(string: "https://api.spotify.com/v1/playlists/3lRvb9RIb0MyUTU4O0IZAv/tracks"),
                total: 1040
            ),
            type: "playlist",
            href: URL(string: "https://api.spotify.com/v1/playlists/3lRvb9RIb0MyUTU4O0IZAv"),
            spotify: URL(string: "https://open.spotify.com/playlist/3lRvb9RIb0MyUTU4O0IZAv")
        )
    }
}
