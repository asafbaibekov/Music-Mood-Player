//
//  PictureInPictureView.swift
//  SwiftUI PiP Try
//
//  Created by Asaf Baibekov on 07/10/2025.
//

import SwiftUI

struct PictureInPictureView<Content: View, BackgroundContent: View>: View {
    
    let content: Content
    
    let backgroundContent: BackgroundContent
    
    @Binding private var windowSize: CGSize
    @Binding private var isHidden: Bool
    
    @State private var dragOffset: CGSize = .zero
    @State private var position: CGSize = .zero
    @State private var deltaPositionByScale: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var isSnappedLeading = true
    @State private var isBelowBounds = false
    
    private let maxScale: CGFloat = 1.25
    private let minScale: CGFloat = 0.75
    
    private let cornerSnapMargin: CGFloat = 0
    
    init(windowSize: Binding<CGSize>, isHidden: Binding<Bool>, @ViewBuilder content: () -> Content, @ViewBuilder backgroundContent: () -> BackgroundContent) {
        self._windowSize = windowSize
        self._isHidden = isHidden
        self.content = content()
        self.backgroundContent = backgroundContent()
    }
    
    var body: some View {
        GeometryReader { screenProxy in
            ZStack {
                backgroundContent
                GeometryReader { proxy in
                    content
                        .cornerRadius(8)
                        .frame(width: windowSize.width, height: windowSize.height)
                        .animation(.linear(duration: 0.1), value: windowSize)
                        .opacity(isHidden ? 0 : 1)
                        .allowsHitTesting(!isHidden)
                        .animation(.spring(response: 0.45, dampingFraction: 1, blendDuration: 0.25), value: isHidden)
                        .scaleEffect(scale, anchor: .center)
                        .offset(
                            x: dragOffset.width + position.width + (isSnappedLeading ? 1 : -1) * deltaPositionByScale.width / 2,
                            y: dragOffset.height + position.height + (!isBelowBounds ? 1 : -1) * deltaPositionByScale.height / 2
                        )
                        .gesture(
                            dragGesture(with: proxy)
                        )
                        .simultaneousGesture(
                            magnifyGesture()
                        )
                }
                .padding()
                .frame(width: screenProxy.size.width, height: screenProxy.size.height)
            }
            .frame(width: screenProxy.size.width, height: screenProxy.size.height)
        }
    }
    
    func dragGesture(with proxy: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged({ value in
                withAnimation(.spring(response: 0.2, dampingFraction: 0.9)) {
                    dragOffset = value.translation
                }
            })
            .onEnded({ value in
                withAnimation() {
                    position.width += value.translation.width
                    position.height += value.translation.height
                    
                    dragOffset = .zero
                    
                    if position.width + (windowSize.width / 2) + ((isSnappedLeading ? 1 : -1) * deltaPositionByScale.width / 2) < proxy.size.width / 2 {
                        position.width = .zero
                        isSnappedLeading = true
                    } else {
                        position.width = proxy.size.width - windowSize.width
                        isSnappedLeading = false
                    }
                    
                    let aboveBounds = position.height < .zero
                    let belowBounds = position.height > (proxy.size.height - windowSize.height - abs(deltaPositionByScale.height))
                    
                    if aboveBounds {
                        position.height = .zero
                        isBelowBounds = false
                    } else if belowBounds {
                        position.height = proxy.size.height - windowSize.height
                        isBelowBounds = true
                    }
                }
            })
    }
    
    func magnifyGesture() -> some Gesture {
        MagnifyGesture()
            .onChanged { gesture in
                withAnimation(.spring(response: 0.2, dampingFraction: 0.9)) {
                    var newScale = lastScale * gesture.magnification
                    newScale = min(max(newScale, minScale), maxScale)
                    scale = newScale
                }
            }
            .onEnded { gesture in
                withAnimation(.spring(response: 0.2, dampingFraction: 0.9)) {
                    let scaledWidth = windowSize.width * scale
                    let scaledHeight = windowSize.height * scale
                    deltaPositionByScale.width = scaledWidth - windowSize.width
                    deltaPositionByScale.height = scaledHeight - windowSize.height
                    lastScale = scale
                }
            }
    }
}

#Preview {
    PictureInPictureView(
        windowSize: .constant(CGSize(width: 140, height: 200)),
        isHidden: .constant(false),
        content: {
            Color.blue
        },
        backgroundContent: {
            Text("Hello, World!")
                .frame(height: 100)
                .background(.green)
        }
    )
}
