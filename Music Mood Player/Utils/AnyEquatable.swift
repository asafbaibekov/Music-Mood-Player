//
//  AnyEquatable.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 13/12/2025.
//

import Foundation

struct AnyEquatable: Equatable {
    
    private let value: any Equatable
    
    private let equals: (any Equatable) -> Bool

    init<T: Equatable>(_ value: T) {
        self.value = value
        self.equals = { other in
            guard let casted = other as? T else { return false }
            return casted == value
        }
    }

    static func == (lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
        lhs.equals(rhs.value)
    }
}

extension Equatable {

    func asAnyEquatable() -> AnyEquatable {
        AnyEquatable(self)
    }
}
