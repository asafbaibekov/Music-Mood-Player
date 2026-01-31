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
    
    var onSelect: ((any PlaylistCellViewModelProtocol) -> Void)?
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16), GridItem(.flexible())
    ]
    
    @State private var dragStartY: CGFloat?
    @State private var isDragging: Bool = false
    @State private var selection: (String)?
    
    var body: some View {
        List(selection: $selection) {
            ForEach(self.playlistCellViewModels, id: \.id) { playlistCellViewModel in
                PlaylistCell(viewModel: playlistCellViewModel)
                    .tag(playlistCellViewModel.id)
                    .onAppear {
                        let last = playlistCellViewModels.last
                        let isLast = last?.asAnyEquatable() == playlistCellViewModel.asAnyEquatable()
                        guard isLast else { return }
                        self.onLastPresented?()
                    }
            }
        }
        .onChange(of: selection, { _, newValue in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation { selection = nil }
            }
            guard let newValue, let onSelect else { return }
            guard let viewModel = playlistCellViewModels.first(where: { $0.id == newValue }) else { return }
            onSelect(viewModel)
        })
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
