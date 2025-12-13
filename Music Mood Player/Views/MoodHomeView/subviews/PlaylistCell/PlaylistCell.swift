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
        VStack(alignment: .leading) {
            GeometryReader { proxy in
                GeometryReader { proxy in
                    KFImage(viewModel.imageURL)
                        .resizable()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .cornerRadius(16)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            
            Text(viewModel.title ?? "")
                .font(.system(size: 16, weight: .semibold))
                .lineLimit(1)
                .padding(.horizontal, 4)
            Text(viewModel.subtitle ?? "")
                .font(.system(size: 14, weight: .semibold))
                .minimumScaleFactor(0.9)
                .lineLimit(1)
                .foregroundStyle(Color.gray)
                .padding(.horizontal, 4)
        }
    }
}

#Preview {
    PlaylistCell(viewModel: SpotifyItem.example)
        .frame(width: 200)
}
