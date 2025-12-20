//
//  PlaylistCellViewModel.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 09/12/2025.
//

import Foundation
import SwiftUI

protocol PlaylistCellViewModelProtocol: Identifiable, Equatable {
    
    var id: String { get }
    
    var title: String? { get }
    
    var subtitle: String? { get }
    
    var imageURL: URL? { get }
    
    var icon: ImageResource { get }
}

struct PlaylistCellViewModel: PlaylistCellViewModelProtocol {
    
    let id = UUID().uuidString
    
    let title: String?
    
    let subtitle: String?
    
    let imageURL: URL?
    
    let icon: ImageResource
}
