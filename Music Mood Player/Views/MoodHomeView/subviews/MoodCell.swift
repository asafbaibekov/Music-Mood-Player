//
//  MoodCell.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 31/10/2025.
//

import SwiftUI

extension MoodHomeView {

    struct MoodCell: View {
        
        let mood: Mood?
        
        @Binding var selectedMood: Mood?
        
        var body: some View {
            let isSelected = selectedMood?.id == mood?.id
            VStack(spacing: 8) {
                ZStack {
                    Group {
                        if mood != nil {
                            Circle().fill(isSelected ? Colors.selected_emoji_bg : Colors.unselected_emoji_bg)
                        } else {
                            Color.clear
                        }
                    }
                    .frame(width: 72, height: 72)
                    Text(mood?.emoji ?? "")
                        .font(.system(size: 34))
                }
                Text(mood?.label ?? "")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.9))
            }
            .onTapGesture { selectedMood = mood }
            .id(mood?.id)
        }
    }
}
