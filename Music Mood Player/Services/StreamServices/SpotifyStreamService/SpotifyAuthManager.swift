//
//  SpotifyAuthManager.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 11/12/2025.
//


import Foundation
import SpotifyiOS
import Combine

final class SpotifyAuthManager: NSObject {
    
    enum AuthError {
//        case loginFailed
//        case renewTokenFailed
        case unknown(Error)
    }
    
    private(set) lazy var sessionManager: SPTSessionManager = {
        let configuration = SPTConfiguration(
            clientID: "2f4647040f594d49a3d0c8369090182c",
            redirectURL: URL(string: "musicmoodplayer://spotify-login-callback")!
        )
        configuration.tokenSwapURL = URL(string: "https://u3irfuz4i3lbxzrux24zytjw7m0dwzva.lambda-url.eu-west-1.on.aws/")!
        configuration.tokenRefreshURL = URL(string: "https://c7x2hf5hzrpsqvzw5int2t65pa0ncjgz.lambda-url.eu-west-1.on.aws/")!
        return SPTSessionManager(configuration: configuration, delegate: self)
    }()
    
    private let sessionStorable: AnyStorable<SPTSession>

    private let isLoggedInSubject = CurrentValueSubject<Bool, Never>(false)
    private let renewSessionSubject = PassthroughSubject<Void, Never>()
    private let authErrorSubject = PassthroughSubject<AuthError, Never>()
    
    private(set) lazy var isLoggedInPublisher: AnyPublisher<Bool, Never> = {
        self.isLoggedInSubject.eraseToAnyPublisher()
    }()
    
    private(set) lazy var renewSessionPublisher: AnyPublisher<Void, Never> = {
        self.renewSessionSubject.eraseToAnyPublisher()
    }()
    
    private(set) lazy var authErrorPublisher: AnyPublisher<AuthError, Never> = {
        self.authErrorSubject.eraseToAnyPublisher()
    }()
    
    var accessToken: String {
        self.sessionManager.session?.accessToken ?? ""
    }

    init(sessionStorable: AnyStorable<SPTSession>) {

        self.sessionStorable = sessionStorable

        super.init()
        self.sessionManager.delegate = self

        if let session = try? sessionStorable.load(), self.sessionManager.session == nil {
            self.sessionManager.session = session
            self.isLoggedInSubject.send(true)
        } else if self.sessionManager.session != nil {
            self.isLoggedInSubject.send(true)
        }
    }

    func login() {
        let scopes: SPTScope = [.playlistReadCollaborative, .playlistReadPrivate, .appRemoteControl]
        self.sessionManager.initiateSession(with: scopes, options: .default, campaign: nil)
    }

    func logout() {
        self.isLoggedInSubject.send(false)
        self.sessionManager.session = nil
        try? self.sessionStorable.delete()
    }

    func renewSession() {
        self.sessionManager.renewSession()
    }
    
    func handleURL(spotifyURL url: URL) {
        let flag = self.sessionManager.application(UIApplication.shared, open: url, options: [:])
        print("\(#function) \(flag)")
    }
}

extension SpotifyAuthManager: SPTSessionManagerDelegate {
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        self.isLoggedInSubject.send(true)
        try? self.sessionStorable.save(session)
    }

    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        self.isLoggedInSubject.send(true)
        try? self.sessionStorable.save(session)
        self.renewSessionSubject.send()
    }

    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        self.logout()
        self.authErrorSubject.send(.unknown(error))
    }
}
