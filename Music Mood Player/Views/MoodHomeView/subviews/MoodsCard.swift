//
//  MoodsCard.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 31/10/2025.
//

import SwiftUI

extension MoodHomeView {

    struct MoodsCard: View {
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
}
