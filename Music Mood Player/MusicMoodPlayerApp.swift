//
//  MusicMoodPlayerApp.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 21/09/2025.
//

import SwiftUI

@main
struct MusicMoodPlayerApp: App {
    
    let viewModel = MoodHomeViewModel()
    
    var body: some Scene {
        WindowGroup {
            MoodHomeView(viewModel: viewModel)
        }
    }
}
