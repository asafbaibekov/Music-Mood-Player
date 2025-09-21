//
//  MoodHomeView.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 21/09/2025.
//

import SwiftUI

struct MoodHomeView: View {
    @StateObject private var viewModel = MoodHomeViewModel()
    @FocusState private var isTextFieldFocused: Bool
    @Namespace private var animation
    
    var body: some View {
        BackgroundView(focusState: _isTextFieldFocused) {
            VStack(spacing: 25) {
                TitleView()
                    .padding(.top, 50)
                
                Spacer()
                
                InputCard(
                    moodText: $viewModel.moodText,
                    showPlaylists: $viewModel.showPlaylists,
                    isTextFieldFocused: _isTextFieldFocused,
                    onTogglePlaylists: {
                        isTextFieldFocused = false
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            viewModel.togglePlaylists()
                        }
                    }
                )
                .padding(.horizontal, 20)
                
                Spacer()
                
                SuggestedPlaylistsSection(showPlaylists: viewModel.showPlaylists, animation: animation)
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

private struct InputCard: View {
    @Binding var moodText: String
    @Binding var showPlaylists: Bool
    @FocusState var isTextFieldFocused: Bool
    
    let onTogglePlaylists: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How are you feeling today?")
                .font(.title3.bold())
                .foregroundColor(.white.opacity(0.9))
            
            TextField("Type your mood...", text: $moodText)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(14)
                .foregroundColor(.white)
                .font(.headline)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isTextFieldFocused ? .white.opacity(0.8) : .clear, lineWidth: 2)
                )
                .padding(.horizontal, 40)
                .focused($isTextFieldFocused)
                .animation(.spring(), value: isTextFieldFocused)
                .submitLabel(.done)
            
            Button(action: onTogglePlaylists) {
                Label(showPlaylists ? "Close Camera" : "Detect with Camera", systemImage: "camera.fill")
                    .font(.headline.bold())
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.9), Color.purple.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .shadow(radius: 6)
                    .scaleEffect(showPlaylists ? 1.05 : 1.0)
            }
            .padding(.horizontal, 40)
        }
        .padding(.vertical, 20)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

private struct SuggestedPlaylistsSection: View {
    let showPlaylists: Bool
    let animation: Namespace.ID
    
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
