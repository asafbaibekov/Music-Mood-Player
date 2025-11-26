//
//  Icons.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 31/10/2025.
//

import SwiftUI

enum Icons {
    
    enum System: String, View {
        
        case faceid
        case checkmark
        case gear
        
        var body: some View {
            Image(systemName: self.rawValue)
        }
    }
    
    enum Custom: String, View {
        
        case spotify
        case apple_music
        case youtube_music
        
        var body: some View {
            Image(rawValue)
        }
        
        var imageResource: ImageResource {
            ImageResource(name: rawValue, bundle: .main)
        }
    }
}
