//
//  Images.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 31/10/2025.
//

import SwiftUI

extension MoodHomeView {
    
    enum Images: String, View {
        case faceid
        case checkmark
        case gear
        
        var body: some View {
            Image(systemName: self.rawValue)
        }
    }
}
