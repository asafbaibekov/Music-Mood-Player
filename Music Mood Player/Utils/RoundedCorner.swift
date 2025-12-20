//
//  RoundedCorner.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 20/12/2025.
//

import SwiftUI

struct RoundedCorner: Shape {
    
    var radius: CGFloat
    
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
