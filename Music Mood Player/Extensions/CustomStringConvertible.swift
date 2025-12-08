//
//  Untitled.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 08/12/2025.
//

import Foundation

extension CustomStringConvertible {
    
    func autoDescription() -> String {
        
        let mirror = Mirror(reflecting: self)
        var output = "\(type(of: self))("

        for (label, value) in mirror.children {
            guard let label else { continue }
            
            let stringValue: String
            switch value {
            case Optional<Any>.none:
                stringValue = "nil"
            case let some as String:
                stringValue = "\"\(some)\""
            case let some as URL:
                stringValue = "\"URL(string: \(some.absoluteString))\""
            case let some as Optional<Any>:
                stringValue = "\(some ?? "nil")"
            default:
                stringValue = "\(value)"
            }

            output += "\(label): \(stringValue), "
        }

        if output.hasSuffix(", ") {
            output.removeLast(2)
        }

        output += ")"
        return output
    }
}
