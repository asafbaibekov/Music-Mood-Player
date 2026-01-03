//
//  RoundedByShortSide.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 03/01/2026.
//

import SwiftUI

struct RoundedByShortSide<Content: View>: View {
    
    @State private var size: CGSize = .zero
    
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(key: SizeKey.self, value: geo.size)
                }
            )
            .onPreferenceChange(SizeKey.self) { size = $0 }
            .clipShape(
                RoundedRectangle(
                    cornerRadius: min(size.width, size.height) / 2
                )
            )
    }
}

private struct SizeKey: PreferenceKey {
    
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
