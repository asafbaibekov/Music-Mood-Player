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
    
    var name: String { get }
    
    var icon: ImageResource { get }
    
    var isLoggedInPublisher: AnyPublisher<Bool, Never> { get }
    
    var playlistsStream: AnyPublisher<[any PlaylistCellViewModelProtocol], Never> { get }
    
    func login()
    
    func logout()
    
    func loadPlaylists()
}

extension MusicStreamService {
    
    var id: UUID {
        UUID()
    }
}
