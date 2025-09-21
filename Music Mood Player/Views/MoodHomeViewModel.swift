//
//  MoodHomeViewModel.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 21/09/2025.
//

import SwiftUI
import Combine

@MainActor
final class MoodHomeViewModel: ObservableObject {
    @Published var moodText: String = ""
    @Published var showPlaylists: Bool = false
    
    func togglePlaylists() {
        showPlaylists.toggle()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
