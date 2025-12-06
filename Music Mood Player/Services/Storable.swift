//
//  Storable.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 06/12/2025.
//

import Foundation

protocol Storable {

    associatedtype StoredType

    func save(_ value: StoredType) throws

    func load() throws -> StoredType?
    
    func delete() throws
}

extension Storable {

    func eraseToAnyStorable() -> AnyStorable<StoredType> {
        return AnyStorable(self)
    }
}

final class AnyStorable<T>: Storable {
    typealias StoredType = T

    private let _save: (T) throws -> Void
    private let _load: () throws -> T?
    private let _delete: () throws -> Void

    init<S: Storable>(_ store: S) where S.StoredType == T {
        self._save = store.save
        self._load = store.load
        self._delete = store.delete
    }

    func save(_ value: T) throws {
        try _save(value)
    }

    func load() throws -> T? {
        try _load()
    }
    
    func delete() throws {
        try _delete()
    }
}
