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
    @Published var showPlaylists: Bool = false
    @Published var selectedMood: Mood? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    let moods: [Mood] = [
        Mood(emoji: "😀", label: "Happy"),
        Mood(emoji: "😢", label: "Sad"),
        Mood(emoji: "😡", label: "Angry"),
        Mood(emoji: "😴", label: "Chill"),
        Mood(emoji: "🤩", label: "Excited"),
        Mood(emoji: "🤔", label: "Thoughtful")
    ]
    
    init() {
        $selectedMood
            .compactMap { $0 }
            .sink { [weak self] _ in
                self?.showPlaylists = true
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            .store(in: &cancellables)
    }
    
    func togglePlaylists() {
        showPlaylists.toggle()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
