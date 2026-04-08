# Development Guide

## Setup

### Prerequisites
- Xcode 15+
- iOS 16+ deployment target
- tvOS 16+ deployment target

### Building the Shared Framework

The `FamousPearsCore` is a Swift Package that contains:
- **Models**: `Duo`, `Player`, `GameRound`, `GameState`
- **GameLogic**: Core game engine with turn management and scoring
- **Validation**: Answer checking with fuzzy matching and typo tolerance
- **CardDatabase**: JSON-based card loader with filtering

### Building iOS App

```bash
cd FamousPearsIOS
xcodebuild -scheme FamousPearsIOS -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Building tvOS App

```bash
cd FamousPearsTVOS
xcodebuild -scheme FamousPearsTVOS -destination 'platform=tvOS Simulator,name=Apple TV'
```

## Architecture

### Shared Framework (FamousPearsCore)
- Handles all game logic, card management, and validation
- No UI dependencies
- Used by both iOS and tvOS apps

### iOS App
- SwiftUI-based player interface
- Handles answer submission
- Shows scores and game state
- Will integrate GameKit for multiplayer

### tvOS App
- Large-screen optimized UI
- Displays current clue and scores
- Acts as game host
- Will support remote control input

## Next Steps

1. **Multiplayer (GameKit)**: Implement peer-to-peer connectivity for iOS-to-iOS play
2. **tvOS Integration**: Connect iOS devices to tvOS host via MultipeerConnectivity
3. **Enhanced UI**: Add animations, sound effects, and visual feedback
4. **More Cards**: Expand card database to 100+ duos
5. **Difficulty Modes**: Add game modes with difficulty filters

## Card Database Format

Cards are stored in `FamousPearsCore/Sources/FamousPearsCore/Resources/cards.json`:

```json
{
  "id": 1,
  "category": "music",
  "member1": "Steely Dan",
  "member2": "Donald Fagen",
  "difficulty": 3,
  "hint": "Jazz-rock duo, 1970s"
}
```

- **difficulty**: 1 (easy) to 5 (hard)
- **member1**: The clue given to the guesser
- **member2**: The answer to guess
