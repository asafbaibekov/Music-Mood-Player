//
//  PlaylistCell.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 09/12/2025.
//

import SwiftUI

struct PlaylistCell: View {
    
    let index: Int
    
    let playlistName: String
    
    let creatorName: String
    
    var body: some View {
        VStack(alignment: .leading) {
            GeometryReader { proxy in
                RoundedRectangle(cornerRadius: 18)
                    .fill(.green.opacity(0.5))
                    .frame(height: proxy.size.width)
                    .overlay(
                        VStack {
                            Image(systemName: "music.note.list")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                            Text("Playlist \(index + 1)")
                                .foregroundColor(.white)
                                .font(.subheadline.bold())
                        }
                    )
            }
            .aspectRatio(1, contentMode: .fit)
            
            Text(playlistName)
                .font(.system(size: 16, weight: .semibold))
                .lineLimit(1)
                .padding(.horizontal, 4)
            Text(creatorName)
                .font(.system(size: 14, weight: .semibold))
                .minimumScaleFactor(0.9)
                .lineLimit(1)
                .foregroundStyle(Color.gray)
                .padding(.horizontal, 4)
        }
    }
}
