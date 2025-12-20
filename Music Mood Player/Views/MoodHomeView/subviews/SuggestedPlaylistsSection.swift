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
    
    private(set) var bottomInset: CGFloat?
    
    var onSwipeDown: (() -> Void)?
    
    var onLastPresented: (() -> Void)?
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16), GridItem(.flexible())
    ]
    
    @State private var dragStartY: CGFloat?
    @State private var isDragging: Bool = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 16) {
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
    let playlistCellViewModels: [PlaylistCellViewModel] = [
        .init(title: "First Playlist", subtitle: "This is the first playlist in the list", imageURL: nil),
        .init(title: "Second Playlist", subtitle: "This is the second playlist in the list", imageURL: nil),
        .init(title: "Third Playlist", subtitle: "This is the third playlist in the list", imageURL: nil)
    ]
    SuggestedPlaylistsSection(playlistCellViewModels: playlistCellViewModels, bottomInset: 0)
}
