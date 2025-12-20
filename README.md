# Music Mood Player

Music Mood Player is an iOS SwiftUI application that surfaces playlists from users' preferred streaming services based on their current mood. Users can explicitly pick a mood or let the device infer it through on-device face analysis powered by TensorFlow. The interface is production-ready. Current efforts focus on wiring up live data sources and TensorFlow inference.

## Key Features
- **Mood-first UX:** Swipe-friendly `MoodsCard` lets listeners pick how they feel and instantly see matching playlists.
- **Playlists per service:** Designed to aggregate Spotify, Apple Music, and YouTube Music recommendations side-by-side.
- **Picture-in-picture camera:** `PictureInPictureView` keeps the camera feed visible while browsing playlists, enabling passive mood detection.
- **Face-based mood detection (WIP):** `FaceExtractorService` prepares video frames for a TensorFlow model that classifies emotions.
- **Ready-made SwiftUI design system:** Centralized colors/icons (`Views/MoodHomeView/assets`) and custom components are in place for consistent UI.

## Architecture Overview
The app uses a lightweight MVVM architecture with three main layers: presentation (SwiftUI views), state & coordination (view models), and integration (services and external SDKs).

```
User
	↓
SwiftUI Views (MoodHomeView, CameraPreviewView, PictureInPictureView)
	↓
View Models (MoodHomeViewModel, CameraPreviewViewModel, PlaylistCellViewModel)
	↓
Domain & Services (Mood model, MusicService, MusicStreamService + stream implementations, FaceExtractorService)
	↓
External Systems (Camera / AVFoundation, TensorFlow model, Spotify SDK, future Apple Music & YouTube Music APIs)
```

### Presentation Layer (Views)
- SwiftUI views such as `MoodHomeView`, `CameraPreviewView`, and `PictureInPictureView` render the UI and bind to observable view models.
- `SuggestedPlaylistsSection` and related subviews display playlists per provider and react to mood and login state changes.

### State & Coordination Layer (View Models)
- `MoodHomeViewModel` (via `MoodHomeViewModelProtocol`) manages the selected mood, which services are active, and which playlists are visible.
- `CameraPreviewViewModel` controls camera lifecycle and exposes bindings used by `CameraPreviewView` and `PictureInPictureView`.
- `PlaylistCellViewModel` represents a single playlist entry produced by a `MusicStreamService` and consumed by the home screen.

### Integration Layer (Services & External APIs)
- `MusicStreamService` defines a common interface for streaming providers; `SpotifyStreamService`, `AppleMusicStreamService`, and `YouTubeMusicStreamService` implement it and talk to their respective backends/SDKs.
- `FaceExtractorService` prepares camera frames for the TensorFlow mood classifier, isolating ML-specific concerns from the UI and view models.
- Storage and helper types (for example the Spotify session storable and basic utilities) support authentication, paging, and result mapping without leaking implementation details into the views.

## Work In Progress
- **Streaming service integrations:** Implement provider-specific API clients, handle OAuth, and map remote playlist data into the common model consumed by the UI toggles.
- **TensorFlow mood inference:** Finalize the TensorFlow model, connect it through `FaceExtractorService`, and update `MoodHomeViewModel` with automatic mood switching and fallbacks.

## Streaming Integrations Status
- `MusicStreamService` defines a common interface for all providers, including login/logout, login state publishing, and async playlist loading.
- `SpotifyStreamService` is wired to the Spotify iOS SDK via `SpotifyAuthManager` and `SpotifyRequestManager`, and currently fetches playlists and maps them into `PlaylistCellViewModel` instances.
- `AppleMusicStreamService` and `YouTubeMusicStreamService` conform to `MusicStreamService` and expose login state publishers, but `loadPlaylists()` is still a stub returning an empty list.
- `SpotifyStreamService` supports paginated loading of playlists and keeps the last response so additional pages can be requested incrementally.

## Roadmap
- Enable direct playback inside the app once service SDKs or playback APIs are connected.
- Surface an in-app player that reflects the current song, including transport controls and artwork.
- Provide a detailed list view for every playlist so users can browse and queue individual songs.
- Mix playlists from all enabled `MusicStreamService` providers into a mixed recommendations feed.
