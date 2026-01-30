//
//  SuggestedPlaylistsSection.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 31/10/2025.
//

import SwiftUI
import Combine

struct SuggestedPlaylistsSection: View {
    
    private(set) var playlistCellViewModels: [any PlaylistCellViewModelProtocol]
    
    var onSwipeDown: (() -> Void)?
    
    var onLastPresented: (() -> Void)?
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16), GridItem(.flexible())
    ]
    
    @State private var dragStartY: CGFloat?
    @State private var isDragging: Bool = false
    
    var body: some View {
        List {
            ForEach(self.playlistCellViewModels, id: \.id) { playlistCellViewModel in
                PlaylistCell(viewModel: playlistCellViewModel)
                    .onAppear {
                        let last = playlistCellViewModels.last
                        let isLast = last?.asAnyEquatable() == playlistCellViewModel.asAnyEquatable()
                        guard isLast else { return }
                        self.onLastPresented?()
                    }
            }
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
    }
}

#Preview {
    let playlistCellViewModels: [PlaylistCellViewModel] = [
        .init(title: "First Playlist", subtitle: "This is the first playlist in the list", imageURL: nil, icon: .spotify),
        .init(title: "Second Playlist", subtitle: "This is the second playlist in the list", imageURL: nil, icon: .appleMusic),
        .init(title: "Third Playlist", subtitle: "This is the third playlist in the list", imageURL: nil, icon: .youtubeMusic)
    ]
    SuggestedPlaylistsSection(playlistCellViewModels: playlistCellViewModels)
}
