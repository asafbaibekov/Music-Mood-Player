//
//  MoodHomeView.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 21/09/2025.
//

import SwiftUI

struct MoodHomeView<ViewModel: MoodHomeViewModelProtocol>: View {
    
    @ObservedObject private(set) var viewModel: ViewModel
    
    @State private var windowSize: CGSize = CGSize(width: 140, height: 200)
    
    @State private var isCardClosed: Bool = false
    
    @State private var cardHeight: CGFloat = 0
    
    private let peekHeight: CGFloat = 38
    
    var body: some View {
        PictureInPictureView(windowSize: $windowSize, isHidden: $viewModel.isCameraHidden) {
            CameraViewRep(isEnabled: $viewModel.isDetecting, viewModel: viewModel.cameraViewModel)
        } backgroundContent: {
            NavigationStack {
                ZStack {
                    GeometryReader { screenProxy in
                        let screenHeight = screenProxy.size.height
                        if viewModel.isShowPlaylists {
                            SuggestedPlaylistsSection(playlistCellViewModels: self.viewModel.playlistCellViewModels, bottomInset: peekHeight + 24) {
                                guard !isCardClosed else { return }
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    isCardClosed = true
                                }
                            }
                        }
                        MoodsCard(
                            moods: viewModel.moods,
                            isShowPlaylists: $viewModel.isShowPlaylists,
                            selectedMood: $viewModel.selectedMood,
                            isHidding: $isCardClosed,
                            onTapHeader: {
                                isCardClosed = false
                            }
                        )
                        .gesture(dragGesture)
                        .offset(y: screenHeight - (isCardClosed ? peekHeight : cardHeight))
                        .padding(.horizontal, 20)
                        .background( // Measure the full card height
                            GeometryReader { proxy in
                                Color.clear
                                    .onAppear { cardHeight = proxy.size.height }
                                    .onChange(of: proxy.size.height) { cardHeight = $1 }
                            }
                        )
                        .animation(.spring(response: 0.35, dampingFraction: 1), value: isCardClosed)
                    }
                }
                .persistentSystemOverlays(isCardClosed ? .hidden : .automatic)
                .toolbar(content: toolbarContent)
                .navigationBarTitleDisplayMode(.automatic)
                .navigationTitle("Music Mood Playlist")
                .onChange(of: viewModel.selectedMood) { _, newMood in
                    guard newMood != nil else { return }
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        self.viewModel.isDetecting = false
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: self.viewModel.isShowPlaylists)
            }
        }
    }
    
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Text("Login / Logout")
                ForEach(viewModel.musicStreamServices, id: \.id) { musicStreamService in
                    ServiceToggleRow(service: musicStreamService)
                }
            } label: {
                if #available(iOS 26, *) {
                    Label(title: { Text("Settings") }, icon: { Icons.System.gear })
                } else {
                    Icons.System.gear
                        .tint(.primary)
                        .padding(8)
                        .clipShape(Circle())
                }
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button {
                viewModel.isDetecting.toggle()
            } label: {
                if #available(iOS 26, *) {
                    Label(title: { Text("Detect") },
                          icon: { (viewModel.isDetecting ? Icons.System.checkmark : Icons.System.faceid) })
                } else {
                    (viewModel.isDetecting ? Icons.System.checkmark : Icons.System.faceid)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Colors.detect_button_bg)
                        .clipShape(Circle())
                }
            }
            .tint(Colors.detect_button_bg)
        }
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard viewModel.isShowPlaylists else { return }
                guard value.translation.height > 50 else { return }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isCardClosed = true
                }
            }
    }
}

#Preview {
    let viewModel = MoodHomeViewModel(musicStreamServices: [
        SpotifyStreamService(sessionStorable: SpotifySessionStorable().eraseToAnyStorable())
    ])
    MoodHomeView(viewModel: viewModel)
}
