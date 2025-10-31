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
        NavigationStack {
            PictureInPictureView(windowSize: $windowSize, isHidden: $viewModel.isCameraHidden) {
                CameraViewRep(isEnabled: $viewModel.isDetecting, viewModel: viewModel.cameraViewModel)
            } backgroundContent: {
                ZStack {
                    GeometryReader { screenProxy in
                        let screenHeight = screenProxy.size.height
                        SuggestedPlaylistsSection(showPlaylists: viewModel.isShowPlaylists, bottomInset: peekHeight + 24) {
                            guard !isCardClosed else { return }
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                isCardClosed = true
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
    @Binding var isHidding: Bool
    
    var onTapHeader: (() -> Void)?
    
    private let columns = 3
    
    var body: some View {
        VStack(spacing: 0) {
            Text("How are you feeling?")
                .font(.title3.bold())
                .padding(.top, 24)
                .onTapGesture {
                    onTapHeader?()
                }
            
            let moodRows = buildGrid(from: moods, columns: columns)
            
            VStack(spacing: 8) {
                ForEach(moodRows.indices, id: \.self) { row in
                    HStack(spacing: 0) {
                        Spacer()
                        ForEach(0..<columns, id: \.self) { column in
                            MoodCell(mood: moodRows[row][column], selectedMood: $selectedMood)
                            if column < columns - 1 {
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                }
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(24)
    }
    
    func buildGrid(from moods: [Mood], columns: Int) -> [[Mood?]] {
        guard columns > 0 else { return [] }
        
        // Split moods into chunks of `columns` size
        let chunked = stride(from: 0, to: moods.count, by: columns).map {
            Array(moods[$0 ..< min($0 + columns, moods.count)])
        }
        
        // Pad the last row (if needed) with nil placeholders
        return chunked.map { row in
            row.count < columns
                ? row + Array(repeating: nil, count: columns - row.count)
                : row
        }
    }
}

private struct MoodCell: View {
    
    let mood: Mood?
    
    @Binding var selectedMood: Mood?
    
    var body: some View {
        let isSelected = selectedMood?.id == mood?.id
        VStack(spacing: 8) {
            ZStack {
                Group {
                    if mood != nil {
                        Circle().fill(isSelected ? Colors.selected_emoji_bg : Colors.unselected_emoji_bg)
                    } else {
                        Color.clear
                    }
                }
                .frame(width: 72, height: 72)
                Text(mood?.emoji ?? "")
                    .font(.system(size: 34))
            }
            Text(mood?.label ?? "")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))
        }
        .onTapGesture { selectedMood = mood }
        .id(mood?.id)
    }
}

private struct SuggestedPlaylistsSection: View {
    
    let showPlaylists: Bool
    
    private(set) var bottomInset: CGFloat?
    
    var onSwipeDown: (() -> Void)? = nil
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16), GridItem(.flexible())
    ]
    
    @State private var lastY: CGFloat = .zero
    @State private var isScrollingDown = false
    @State private var lastTriggerTime: Date = .distantPast
    
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
            .onScrollGeometryChange(
                for: CGFloat.self,
                of: { geometry in
                    geometry.contentOffset.y
                },
                action: { oldValue, newValue in
                    let delta = newValue - oldValue
                    
                    // Ignore small noise and negative offset
                    guard abs(delta) > 3, newValue > 0 else { return }
                    
                    // Detect scroll down
                    guard delta > 0 else { return }
                    
                    let now = Date()
                    
                    // Trigger only if at least 0.3s passed since last trigger
                    guard now.timeIntervalSince(lastTriggerTime) > 0.3 else { return }
                    lastTriggerTime = now
                    onSwipeDown?()
                }
            )
            .safeAreaInset(edge: .bottom) {
                Spacer().frame(height: bottomInset)
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
