//
//  YouTubeMusicStreamService.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 27/11/2025.
//

import Foundation
import SwiftUI
import Combine

final class YouTubeMusicStreamService: MusicStreamService {
    
    var name: String = "Youtube Music"
    
    var icon: ImageResource = Icons.Custom.youtube_music.imageResource
    
    let isLoggedInSubject = CurrentValueSubject<Bool, Never>(false)
    
    func login() {
        self.isLoggedInSubject.value = true
        print("\(name) logged in")
    }
    
    func logout() {
        self.isLoggedInSubject.value = false
        print("\(name) logged out")
    }
}
