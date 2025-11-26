//
//  ServiceToggleRow.swift
//  Music Mood Player
//
//  Created by Asaf Baibekov on 26/11/2025.
//

import SwiftUI
import Combine

extension MoodHomeView {
    
    struct ServiceToggleRow: View {
        @StateObject private var viewModel: ServiceToggleRowViewModel
        
        init(service: any MusicStreamService) {
            self._viewModel = StateObject(wrappedValue: ServiceToggleRowViewModel(service))
        }
        
        var body: some View {
            Toggle(
                viewModel.name,
                image: viewModel.icon,
                isOn: Binding(
                    get: { viewModel.isLoggedIn },
                    set: { newValue in
                        if newValue {
                            viewModel.login()
                        } else {
                            viewModel.logout()
                        }
                    }
                )
            )
            .onReceive(viewModel.isLoggedInPublisher) { newValue in
                viewModel.isLoggedIn = newValue
            }
        }
    }
    
    private final class ServiceToggleRowViewModel: ObservableObject {
        
        @Published var isLoggedIn: Bool = false
        
        let name: String
        
        let icon: ImageResource
        
        private let service: any MusicStreamService
        
        var isLoggedInPublisher: AnyPublisher<Bool, Never> {
            self.service.isLoggedInSubject
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
        
        init(_ service: any MusicStreamService) {
            self.name = service.name
            self.icon = service.icon
            self.service = service
        }
        
        func login() {
            service.login()
        }
        
        func logout() {
            service.logout()
        }
    }
}
