//
//  AppleMusicStreamService.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 27/11/2025.
//

import Foundation
import SwiftUI
import Combine

final class AppleMusicStreamService: MusicStreamService {
    
    var musicService: MusicService { .appleMusic }
    
    private(set) lazy var isLoggedInPublisher: AnyPublisher<Bool, Never> = {
        self.isLoggedInSubject.eraseToAnyPublisher()
    }()
    
    private let isLoggedInSubject = CurrentValueSubject<Bool, Never>(false)
    
    func login() {
        self.isLoggedInSubject.value = true
        print("\(musicService.name) logged in")
    }
    
    func logout() {
        self.isLoggedInSubject.value = false
        print("\(musicService.name) logged out")
    }
    
    func loadPlaylists() async throws -> [any PlaylistCellViewModelProtocol] {
        return []
    }
}
