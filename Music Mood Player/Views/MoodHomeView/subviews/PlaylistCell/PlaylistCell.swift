//
//  PlaylistCell.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 09/12/2025.
//

import SwiftUI

struct PlaylistCell: View {
    
    let viewModel: PlaylistCellViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            GeometryReader { proxy in
                RoundedRectangle(cornerRadius: 18)
                    .fill(.green.opacity(0.5))
                    .frame(height: proxy.size.width)
            }
            .aspectRatio(1, contentMode: .fit)
            
            Text(viewModel.title)
                .font(.system(size: 16, weight: .semibold))
                .lineLimit(1)
                .padding(.horizontal, 4)
            Text(viewModel.subtitle)
                .font(.system(size: 14, weight: .semibold))
                .minimumScaleFactor(0.9)
                .lineLimit(1)
                .foregroundStyle(Color.gray)
                .padding(.horizontal, 4)
        }
    }
}

#Preview {
    let viewModel = PlaylistCellViewModel(title: "Title", subtitle: "Subtitle")
    PlaylistCell(viewModel: viewModel)
        .frame(width: 200)
}
