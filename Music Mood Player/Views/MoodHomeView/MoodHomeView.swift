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
                        ZStack {
                            switch viewModel.contentState {
                            case .noneLoggedIn:
                                MessageView(for: .login)
                                    .frame(height: max(0, screenHeight - cardHeight))
                            case .unselectedMood:
                                MessageView(for: .detection)
                                    .frame(height: max(0, screenHeight - cardHeight))
                            case .showPlaylists(let mood):
                                SuggestedPlaylistsSection(
                                    playlistCellViewModels: self.viewModel.playlistCellViewModels,
                                    bottomInset: self.peekHeight + 24,
                                    onSwipeDown: {
                                        guard !isCardClosed else { return }
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            isCardClosed = true
                                        }
                                    },
                                    onLastPresented: {
                                        self.viewModel.loadPlaylists()
                                    }
                                )
                            }
                        }
                        MoodsCard(
                            moods: viewModel.moods,
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
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: self.viewModel.contentState.isShowPlaylists)
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
                guard viewModel.contentState.isShowPlaylists else { return }
                guard value.translation.height > 50 else { return }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isCardClosed = true
                }
            }
    }
    
    @ViewBuilder
    func MessageView(for state: ButtonState) -> some View {
        VStack(alignment: .center, spacing: 16) {
            Circle()
                .fill(.selectedEmojiBg)
                .overlay(
                    Image(systemName: "music.note.list")
                        .resizable()
                        .foregroundColor(.detectButtonBg)
                        .frame(width: 24, height: 24)
                )
                .frame(width: 48, height: 48)
            VStack(alignment: .center, spacing: 4) {
                Text("No playlists yet")
                    .fontWeight(.semibold)
                Text("Pick a mood or let us detect it for you")
                    .fontWeight(.medium)
                    .foregroundStyle(.gray)
            }
            switch state {
            case .login:
                Menu(
                    content: {
                        Text("Login / Logout")
                        ForEach(viewModel.musicStreamServices, id: \.id) { musicStreamService in
                            ServiceToggleRow(service: musicStreamService)
                        }
                    },
                    label: {
                        makeButtonLabel(for: state)
                    }
                )
            case .detection:
                Button(
                    action: {
                        viewModel.isDetecting.toggle()
                    },
                    label: {
                        makeButtonLabel(for: state)
                    }
                )
            }
            
        }
        .frame(maxWidth: .infinity)
    }
    
    func makeButtonLabel(for state: ButtonState) -> some View {
        let view = Label(
            title: { Text(state.title).font(.system(size: 20, weight: .semibold)) },
            icon: { state.icon.image.resizable().frame(width: 28, height: 28) }
        )
        .padding(.vertical, 14)
        .padding(.horizontal, 24)
        
        if #available(iOS 26.0, *) {
            return view
                .foregroundStyle(.white)
                .glassEffect(.clear.tint(state.backgroundColor))
        }
        return RoundedByShortSide(content: {
            view
                .foregroundStyle(.white)
                .background(state.backgroundColor)
                .background(Material.ultraThick)
        })
    }
    
    enum ButtonState {
        case login
        case detection
        
        var title: String {
            switch self {
            case .login: "Settings"
            case .detection: "Detect Mood"
            }
        }
        
        var icon: Icons.System {
            switch self {
            case .login: .gear
            case .detection: .faceid
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .login: .gray.opacity(0.75)
            case .detection: .detectButtonBg
            }
        }
    }
}

#Preview {
    let viewModel = MoodHomeViewModel(musicStreamServices: [
        SpotifyStreamService(sessionStorable: SpotifySessionStorable().eraseToAnyStorable()),
        YouTubeMusicStreamService()
    ])
    MoodHomeView(viewModel: viewModel)
}
