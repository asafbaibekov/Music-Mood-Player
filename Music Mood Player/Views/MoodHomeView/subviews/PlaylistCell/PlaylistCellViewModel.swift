//
//  PlaylistCellViewModel.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 09/12/2025.
//

import Foundation

class PlaylistCellViewModel: ObservableObject {
    
    let title: String
    
    let subtitle: String
    
    init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
}
