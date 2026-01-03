//
//  Mood.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 21/09/2025.
//

import Foundation

enum Mood: Identifiable, CaseIterable {
    case happy
    case sad
    case angry
    case chill
    case excited
    case thoughtful
   
    var id: String { title }
    
    var title: String {
        String(describing: self).capitalized
    }
    
    var emoji: String {
        switch self {
        case .happy: return "😀"
        case .sad: return "😢"
        case .angry: return "😡"
        case .chill: return "😴"
        case .excited: return "🤩"
        case .thoughtful: return "🤔"
        }
    }
}
