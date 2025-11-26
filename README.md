# Music Mood Player

Music Mood Player is an iOS SwiftUI application that surfaces playlists from users' preferred streaming services based on their current mood. Users can explicitly pick a mood or let the device infer it through on-device face analysis powered by TensorFlow. The interface is production-ready. Current efforts focus on wiring up live data sources and TensorFlow inference.

## Key Features
- **Mood-first UX:** Swipe-friendly `MoodsCard` lets listeners pick how they feel and instantly see matching playlists.
- **Playlists per service:** Designed to aggregate Spotify, Apple Music, and YouTube Music recommendations side-by-side.
- **Picture-in-picture camera:** `PictureInPictureView` keeps the camera feed visible while browsing playlists, enabling passive mood detection.
- **Face-based mood detection (WIP):** `FaceExtractorService` prepares video frames for a TensorFlow model that classifies emotions.
- **Ready-made SwiftUI design system:** Centralized colors/icons (`Views/MoodHomeView/assets`) and custom components are in place for consistent UI.

## Architecture Overview
The app embraces a lightweight MVVM structure with explicit separation of UI, logic, and services.

```
Music Mood Player
├── Models
│   └── Mood.swift                 // Defines mood metadata and display helpers
├── Services
│   └── FaceExtractorService.swift // Handles frame capture + preprocessing for ML
├── Views
│   ├── MoodHomeView               // Entry point that orchestrates moods & playlists
│   │   ├── subviews               // `MoodCell`, `MoodsCard`, `SuggestedPlaylistsSection`
│   │   └── assets                 // Shared `Colors` and `Icons`
│   └── CameraPreviewView          // Camera pipeline (SwiftUI ↔ AVFoundation bridge)
│       ├── CameraPreviewViewModel // Business logic & state
│       ├── CameraPreviewModels    // DTOs/state structs
│       └── CameraViewRep          // UIViewRepresentable wrapper for AVCaptureSession
└── Music Mood PlayerApp.swift     // Bootstraps `MoodHomeView` with default ViewModels
```

### Data & View Models
- `MoodHomeViewModel` (conforms to `MoodHomeViewModelProtocol`) manages selected mood, playlist visibility, and camera state.
- `CameraPreviewViewModel` encapsulates capture session lifecycle, providing bindings to `PictureInPictureView` and the face extractor.

### Services Layer
- `FaceExtractorService` abstracts away frame extraction and normalization so the eventual TensorFlow model can focus on inference-only.
- Future service adapters will live alongside it (e.g., `SpotifyPlaylistService`, `AppleMusicPlaylistService`).

### UI Layer
- Components are composed in `MoodHomeView`, using a custom `PictureInPictureView` for the floating camera and a toolbar for auth/detection toggles.
- `SuggestedPlaylistsSection` will render provider-specific grids using data injected from streaming service adapters.

## Work In Progress
- **Streaming service integrations:** Implement provider-specific API clients, handle OAuth, and map remote playlist data into the common model consumed by the UI toggles.
- **TensorFlow mood inference:** Finalize the TensorFlow model, connect it through `FaceExtractorService`, and update `MoodHomeViewModel` with automatic mood switching and fallbacks.

## Roadmap
- Enable direct playback inside the app once service SDKs or playback APIs are connected.
- Surface an in-app player that reflects the current song, including transport controls and artwork.
- Provide a detailed list view for every playlist so users can browse and queue individual songs.
