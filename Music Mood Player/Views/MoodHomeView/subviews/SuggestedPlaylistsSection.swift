//
//  SuggestedPlaylistsSection.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 31/10/2025.
//

import SwiftUI

extension MoodHomeView {
    
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
                            
                            Text("Playlist name")
                                .font(.system(size: 16, weight: .semibold))
                                .lineLimit(1)
                                .padding(.horizontal, 4)
                            Text("Creator name")
                                .font(.system(size: 14, weight: .semibold))
                                .minimumScaleFactor(0.9)
                                .lineLimit(1)
                                .foregroundStyle(Color.gray)
                                .padding(.horizontal, 4)
                        }
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
            .safeAreaInset(edge: .bottom) {
                Spacer().frame(height: bottomInset)
            }
            .padding(.horizontal, 20)
        }
    }
}
