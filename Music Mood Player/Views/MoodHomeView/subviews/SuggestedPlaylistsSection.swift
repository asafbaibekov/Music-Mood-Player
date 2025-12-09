//
//  SuggestedPlaylistsSection.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 31/10/2025.
//

import SwiftUI

struct SuggestedPlaylistsSection: View {
    
    private(set) var bottomInset: CGFloat?
    
    var onSwipeDown: (() -> Void)? = nil
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16), GridItem(.flexible())
    ]
    
    @State private var dragStartY: CGFloat?
    @State private var isDragging: Bool = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(0..<23, id: \.self) { index in
                    PlaylistCell(index: index, playlistName: "Playlist name", creatorName: "Creator name")
                }
            }
            .padding(.bottom, bottomInset)
        }
        .onScrollGeometryChange(
            for: CGFloat.self,
            of: { geometry in
                geometry.contentOffset.y
            },
            action: { oldValue, newValue in
                guard isDragging, newValue - oldValue > 3 else { return }
                onSwipeDown?()
            }
        )
        .simultaneousGesture(
            DragGesture()
                .onChanged { _ in isDragging = true }
                .onEnded { _ in isDragging = false }
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    SuggestedPlaylistsSection(bottomInset: 0)
}
