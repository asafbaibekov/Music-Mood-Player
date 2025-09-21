//
//  MoodHomeView.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 21/09/2025.
//

import SwiftUI

struct MoodHomeView: View {
    @StateObject private var viewModel = MoodHomeViewModel()
    
    var body: some View {
        BackgroundView {
            VStack(spacing: 25) {
                TitleView()
                    .padding(.top, 50)
                
                Spacer()
                
                InputCard(
                    moods: viewModel.moods,
                    showPlaylists: $viewModel.showPlaylists,
                    selectedMood: $viewModel.selectedMood,
                    onTogglePlaylists: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            viewModel.togglePlaylists()
                        }
                    }
                )
                .padding(.horizontal, 20)
                
                Spacer()
                
                SuggestedPlaylistsSection(showPlaylists: viewModel.showPlaylists)
                    .padding(.bottom, 40)
            }
        }
    }
}

private struct BackgroundView<Content: View>: View {
    @FocusState var focusState: Bool
    
    let content: () -> Content
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            content()
                .contentShape(Rectangle())
                .onTapGesture {
                    focusState = false
                }
        }
    }
}

private struct TitleView: View {
    let topLabelSize: CGFloat = 28
    let bottomLabelSize: CGFloat = 20
    
    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            Text("🎵")
                .font(.system(size: topLabelSize, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .shadow(radius: 6)
                .transition(.opacity.combined(with: .scale))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Music Mood Player")
                    .font(.system(size: topLabelSize, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(radius: 6)
                    .transition(.opacity.combined(with: .scale))
                Text("Find playlists that match your vibe")
                    .font(.system(size: bottomLabelSize, weight: .regular, design: .default))
                    .foregroundColor(.white.opacity(0.85))
            }
        }
    }
}

private struct MoodCarousel: View {
    let moods: [Mood]
    @Binding var selectedMood: Mood?
    
    var body: some View {
        GeometryReader { geo in
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 18) {
                        ForEach(moods) { mood in
                            VStack(spacing: 16) {
                                let isSelected = selectedMood?.id == mood.id
                                Text(mood.emoji)
                                    .font(.system(size: isSelected ? 38 : 34))
                                    .padding(12)
                                    .background(
                                        Circle()
                                            .fill(isSelected ? .white.opacity(0.35) : .white.opacity(0.15))
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(isSelected ? .white : .clear, lineWidth: 3)
                                    )
                                    .shadow(color: isSelected ? .white.opacity(0.8) : .clear, radius: 10)
                                    .scaleEffect(isSelected ? 1.2 : 1.0)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            selectedMood = mood
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            proxy.scrollTo(mood.id, anchor: .center)
                                        }
                                    }
                                
                                Text(mood.label)
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .id(mood.id)
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal, geo.size.width / 2 - 35)
                }
                .scrollTargetBehavior(.viewAligned)
                .onAppear {
                    moods.first.map { first in
                        selectedMood = first
                        DispatchQueue.main.async {
                            proxy.scrollTo(first.id, anchor: .center)
                        }
                    }
                }
            }
        }
    }
}

private struct InputCard: View {
    let moods: [Mood]
    
    @Binding var showPlaylists: Bool
    @Binding var selectedMood: Mood?
    @FocusState var isTextFieldFocused: Bool
    
    let onTogglePlaylists: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text("How are you feeling today?")
                .font(.title3.bold())
                .foregroundColor(.white.opacity(0.9))
            
            MoodCarousel(moods: moods, selectedMood: $selectedMood)
            
            Button(action: onTogglePlaylists) {
                Label("Detect with Camera", systemImage: "camera.fill")
                    .font(.headline.bold())
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(colors: [.blue.opacity(0.9), .purple.opacity(0.9)], startPoint: .leading, endPoint: .trailing)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .shadow(radius: 6)
            }
        }
        .frame(minHeight: 200, maxHeight: 230)
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

private struct SuggestedPlaylistsSection: View {
    let showPlaylists: Bool
    
    @Namespace private var animation
    
    var body: some View {
        if showPlaylists {
            VStack(alignment: .leading, spacing: 15) {
                Text("🎧 Suggested Playlists")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 25)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(0..<3, id: \.self) { index in
                            PlaylistCard(index: index, animation: animation)
                        }
                    }
                    .padding(.horizontal, 25)
                }
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        } else {
            Text("No playlists yet — type a mood or use camera 🎭")
                .foregroundColor(.white.opacity(0.7))
                .font(.footnote)
                .transition(.opacity)
        }
    }
}

private struct PlaylistCard: View {
    let index: Int
    let animation: Namespace.ID
    
    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(.white.opacity(0.2))
            .frame(width: 180, height: 200)
            .overlay(
                VStack {
                    Image(systemName: "music.note.list")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Text("Playlist \(index+1)")
                        .foregroundColor(.white)
                        .font(.subheadline.bold())
                }
            )
            .shadow(radius: 8)
            .matchedGeometryEffect(id: "playlist\(index)", in: animation)
    }
}

#Preview {
    MoodHomeView()
}
