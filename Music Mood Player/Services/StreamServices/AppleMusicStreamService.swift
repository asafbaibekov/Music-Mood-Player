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
    
    var name: String = "Apple Music"
    
    var icon: ImageResource = Icons.Custom.apple_music.imageResource
    
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
