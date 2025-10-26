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
    
    var body: some View {
        NavigationStack {
            PictureInPictureView(windowSize: $windowSize, isHidden: $viewModel.isCameraHidden) {
                CameraViewRep(isEnabled: $viewModel.isDetecting, viewModel: viewModel.cameraViewModel)
            } backgroundContent: {
                ZStack {
                    SuggestedPlaylistsSection(showPlaylists: viewModel.isShowPlaylists)
                    
                    VStack(spacing: 25) {
                        
                        Spacer()
                        
                        MoodsCard(
                            moods: viewModel.moods,
                            isShowPlaylists: $viewModel.isShowPlaylists,
                            selectedMood: $viewModel.selectedMood
                        )
                        .padding(.horizontal, 20)
                    }
                }
            }
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
    
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        
        ToolbarItem(placement: .topBarLeading) {
            Button {
                
            } label: {
                if #available(iOS 26, *) {
                    Label(title: { Text("Settings") }, icon: { Images.gear })
                } else {
                    Images.gear
                        .tint(.black)
                        .padding(8)
                        .background(Colors.unselected_emoji_bg)
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
                          icon: { (viewModel.isDetecting ? Images.checkmark : Images.faceid) })
                } else {
                    (viewModel.isDetecting ? Images.checkmark : Images.faceid)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Colors.detect_button_bg)
                        .clipShape(Circle())
                }
            }
            .tint(Colors.detect_button_bg)
        }
    }
}

private struct MoodsCard: View {
    let moods: [Mood]

    @Binding var isShowPlaylists: Bool
    @Binding var selectedMood: Mood?
    
    private let columns: [GridItem] = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            Text("How are you feeling?")
                .font(.title3.bold())
                .padding(.top, 24)
            
            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(moods) { mood in
                    let isSelected = selectedMood?.id == mood.id
                    VStack(spacing: 8) {
                        Text(mood.emoji)
                            .font(.system(size: 34))
                            .frame(width: 72, height: 72)
                            .background(
                                Circle()
                                    .fill(isSelected ? Colors.selected_emoji_bg : Colors.unselected_emoji_bg)
                            )
                        
                        Text(mood.label)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .onTapGesture {
                        selectedMood = mood
                    }
                    .id(mood.id)
                }
            }
            .padding(24)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(24)
    }
}

private struct SuggestedPlaylistsSection: View {
    
    let showPlaylists: Bool
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16), GridItem(.flexible())
    ]
    
    var body: some View {
        if showPlaylists {
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
            .padding(.horizontal, 20)
        }
    }
}

private enum Images: String, View {
    case faceid
    case checkmark
    case gear
    
    var body: some View {
        Image(systemName: self.rawValue)
    }
}

private enum Colors: String, ShapeStyle {
    
    case detect_button_bg
    case selected_emoji_bg
    case unselected_emoji_bg
    
    func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        Color(rawValue)
    }
}

#Preview {
    let viewModel = MoodHomeViewModel()
    MoodHomeView(viewModel: viewModel)
}
