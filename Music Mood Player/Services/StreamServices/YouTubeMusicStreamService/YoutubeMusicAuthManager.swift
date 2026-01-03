//
//  YoutubeMusicAuthManager.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 31/12/2025.
//

import Combine
import GoogleSignIn

class YoutubeMusicAuthManager {
    
    private let isLoggedInSubject = CurrentValueSubject<Bool, Never>(false)
    
    private(set) lazy var isLoggedInPublisher: AnyPublisher<Bool, Never> = {
        self.isLoggedInSubject.eraseToAnyPublisher()
    }()
    
    private var user: GIDGoogleUser?
    
    var accessToken: String {
        user?.accessToken.tokenString ?? ""
    }
    
    init() {
        Task { [weak self] in
            let user = try await GIDSignIn.sharedInstance
                .restorePreviousSignIn()
                .refreshTokensIfNeeded()
            self?.user = user
            self?.isLoggedInSubject.send(true)
        }
    }
    
    func handleURL(googleURL url: URL) {
        GIDSignIn.sharedInstance.handle(url)
    }
    
    func login() {
        guard let presentingViewController = UIApplication.shared.rootViewController else {
            assertionFailure("No rootViewController found")
            return
        }
        
        Task { @MainActor [weak self] in
            do {
                let user = try await GIDSignIn.sharedInstance
                    .signIn(withPresenting: presentingViewController)
                    .user.refreshTokensIfNeeded()
                self?.user = user
                self?.isLoggedInSubject.send(true)
            } catch {
                print(error)
                self?.isLoggedInSubject.send(false)
            }
        }
    }
    
    func logout() {
        GIDSignIn.sharedInstance.signOut()
        self.user = nil
        isLoggedInSubject.send(false)
    }
}
