//
//  MusicService.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 20/12/2025.
//

import SwiftUI

enum MusicService {
    
    case spotify
    
    case appleMusic
    
    case youtubeMusic
    
    var name: String {
        switch self {
        case .spotify: "Spotify"
        case .appleMusic: "Apple Music"
        case .youtubeMusic: "Youtube Music"
        }
    }
    
    var imageResource: ImageResource {
        switch self {
        case .spotify: Icons.Custom.spotify.imageResource
        case .appleMusic: Icons.Custom.apple_music.imageResource
        case .youtubeMusic: Icons.Custom.youtube_music.imageResource
        }
    }
}
