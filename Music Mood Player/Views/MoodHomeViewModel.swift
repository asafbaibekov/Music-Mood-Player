//
//  MoodHomeViewModel.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 21/09/2025.
//

import SwiftUI
import Combine

@MainActor
protocol MoodHomeViewModelProtocol: ObservableObject {
    
    var isDetecting: Bool { get set }
    
    var selectedMood: Mood? { get set }
    
    var moods: [Mood] { get }
}

@MainActor
final class MoodHomeViewModel: MoodHomeViewModelProtocol {
    
    @Published var isDetecting: Bool = false
    
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
}
