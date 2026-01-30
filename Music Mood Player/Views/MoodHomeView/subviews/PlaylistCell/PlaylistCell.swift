//
//  PlaylistCell.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 09/12/2025.
//

import SwiftUI
import Kingfisher

struct PlaylistCell: View {
    
    let viewModel: any PlaylistCellViewModelProtocol
    
    var body: some View {
        HStack(alignment: .top) {
            GeometryReader { proxy in
                ZStack(alignment: .bottom) {
                    KFImage(viewModel.imageURL)
                        .resizable()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .cornerRadius(16)
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .black.opacity(0),
                                    .black.opacity(0.25),
                                    .black.opacity(0.5),
                                    .black.opacity(0.75),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(
                            RoundedCorner(radius: 16, corners: [.bottomLeft, .bottomRight])
                        )
                        .frame(width: proxy.size.width, height: proxy.size.height/4)
                    HStack(spacing: 0) {
                        Image(viewModel.icon)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(8)
                        Spacer()
                    }
                    .frame(width: proxy.size.width)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            VStack(alignment: .leading) {
                Text(viewModel.title ?? "")
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)
                
                Text(viewModel.subtitle ?? "")
                    .font(.system(size: 14, weight: .semibold))
                    .minimumScaleFactor(0.9)
                    .foregroundStyle(Color.gray)
            }
            .padding(.vertical, 8)
            Spacer()
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    PlaylistCell(viewModel: SpotifyItem.example)
}
