//
//  Colors.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 31/10/2025.
//

import SwiftUI
extension MoodHomeView {
    
    enum Colors: String, ShapeStyle {
        
        case detect_button_bg
        case selected_emoji_bg
        case unselected_emoji_bg
        
        func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
            Color(rawValue)
        }
    }
}
