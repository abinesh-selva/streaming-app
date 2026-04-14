# Cricfy TV Clone - Flutter Implementation Plan

We are pivoting to a **100% Native Flutter** architecture. This will provide the "Cricfy TV" experience with better frame rates, native video player controls, and superior memory management for streaming.

## User Review Required

> [!IMPORTANT]
> **Native Switch**: All React + Vite code will serve as the architectural reference. The production mobile app will be built in **Dart**.
> [!NOTE]
> **Video Engine**: We will use `video_player` with `chewie` for a polished UI, or `better_player` if advanced HLS quality switching is required natively.

## Proposed Changes

### 1. Technology Stack (Native)
- **Framework**: **Flutter 3.x**.
- **State Management**: `Provider` or `Riverpod` for clean data flow.
- **Video Playback**: `chewie` + `video_player` (HLS/m3u8 compatible).
- **Styling**: `CustomPainter` for the team shields and `BackdropFilter` for the premium Glassmorphic UI.
- **Icons**: `lucide_icons` (Flutter version).

---

### 2. Flutter Component Roadmap

#### Home Layout
- **Custom App Bar**: Transparent glass effect with the CricfyTV logo.
- **Match Card Widget**: Custom card with pulsing live indicators and team shields.
- **Category Grid**: Interactive tiles with micro-interactions.

#### Player & Server Selection
- **Player View**: Full-screen capable video engine.
- **Tab Controller**: Native Material Tabs below the player for "Servers" and "Scorecard".
- **Dynamic Theming**: The player UI will adapt its accent color based on the selected match (e.g., Yellow accents for CSK matches).

#### Data & Networking
- **MatchService**: An abstract service to fetch match data (initially from local JSON, later from a REST/SSE API).
- **IPL Team Models**: Strongly typed models for the 10 IPL teams and their branding.

---

### 3. Aesthetics & UX (Flutter)
- **Blur Effects**: Using `ImageFilter.blur` to achieve the glassmorphism surface.
- **Transitions**: Smooth `Hero` animations when transitioning from a Match Card to the Video Player.
- **Typography**: Integrating 'Inter' font via `google_fonts`.

## Open Questions
- **Q1**: Do you have a preferred Flutter state management library (e.g., Provider, Bloc, or simple setState for the prototype)?
- **Q2**: Should I initialize the Flutter project as `cricfy_tv_flutter` in the `myInnov` directory?
- **Q3**: For the video player, do you prefer a basic UI (Chewie) or a completely custom-skinned player?

## Verification Plan

### Automated Tests
- **Widget Testing**: Ensure the glassmorphic cards render correctly.

### Manual Verification
- **HLS Stream Test**: Verify that the `.m3u8` test streams play smoothly on the native player.
- **Orientation Check**: Ensure the player handles landscape mode correctly.
