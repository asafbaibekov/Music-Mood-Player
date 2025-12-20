//
//  MusicStreamService.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 26/11/2025.
//

import Foundation
import SwiftUI
import Combine

protocol MusicStreamService: Identifiable {
    
    var id: UUID { get }
    
    var musicService: MusicService { get }
    
    var isLoggedInPublisher: AnyPublisher<Bool, Never> { get }
    
    func login()
    
    func logout()
    
    func loadPlaylists() async throws -> [any PlaylistCellViewModelProtocol]
}

extension MusicStreamService {
    
    var id: UUID {
        UUID()
    }
}
