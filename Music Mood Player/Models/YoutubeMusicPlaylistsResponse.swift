//
//  YoutubeMusicPlaylistsResponse.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 31/12/2025.
//

import Foundation

struct YoutubeMusicPlaylistsResponse: Decodable, CustomStringConvertible {

    let totalResults: Int
    let resultsPerPage: Int
    let nextPageToken: String?
    let regionCode: String
    let items: [YoutubeMusicItem]
    
    var description: String { autoDescription() }

    enum CodingKeys: String, CodingKey {
        case pageInfo
        case nextPageToken
        case regionCode
        case items
    }

    enum PageInfoKeys: String, CodingKey {
        case totalResults
        case resultsPerPage
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.nextPageToken = try container.decodeIfPresent(String.self, forKey: .nextPageToken)
        self.regionCode = try container.decode(String.self, forKey: .regionCode)
        self.items = try container.decode([YoutubeMusicItem].self, forKey: .items)

        let pageInfoContainer = try container.nestedContainer(keyedBy: PageInfoKeys.self, forKey: .pageInfo)
        self.totalResults = try pageInfoContainer.decode(Int.self, forKey: .totalResults)
        self.resultsPerPage = try pageInfoContainer.decode(Int.self, forKey: .resultsPerPage)
    }
}
