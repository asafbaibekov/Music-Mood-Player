//
//  UIApplication.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 31/12/2025.
//


import UIKit

extension UIApplication {
    
    var rootViewController: UIViewController? {
        self.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
