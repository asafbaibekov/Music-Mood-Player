//
//  Result.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 19/12/2025.
//

extension Result {
    
    init(async work: () async throws -> Success) async where Failure == Error {
        do {
            self = .success(try await work())
        } catch {
            self = .failure(error)
        }
    }
}
