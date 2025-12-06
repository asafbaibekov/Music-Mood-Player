//
//  SpotifySessionStorable.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 06/12/2025.
//


import Valet
import SpotifyiOS.SPTSession

struct SpotifySessionStorable: Storable {
    
    private let valet = Valet.iCloudValet(with: Identifier(nonEmpty: "SpotifySecrets")!, accessibility: .whenUnlocked)
    
    private var key: String { "spotify_session" }
    
    func save(_ value: SPTSession) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true)
        try valet.setObject(data, forKey: self.key)
    }
    
    func load() throws -> SPTSession? {
        let data = try valet.object(forKey: self.key)
        return try NSKeyedUnarchiver.unarchivedObject(ofClass: SPTSession.self, from: data)
    }
    
    func delete() throws {
        try valet.removeObject(forKey: self.key)
    }
}
