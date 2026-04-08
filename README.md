# Famous Peers

A multiplayer iOS/tvOS game where players guess famous duos based on one member's name.

## Quick Start

### Generate Xcode Projects

```bash
brew install xcodegen  # if not already installed
./scripts/generate-projects.sh
```

Or manually:

```bash
cd FamousPeersIOS && xcodegen generate && cd ..
cd FamousPeersTVOS && xcodegen generate && cd ..
```

Then open in Xcode:

```bash
open FamousPeersIOS/FamousPeersIOS.xcodeproj
open FamousPeersTVOS/FamousPeersTVOS.xcodeproj
```

## Architecture

- **FamousPeersCore**: Shared Swift Package with game logic, card database, validation, networking, and audio
- **FamousPeersIOS**: iOS app for players (iPhone/iPad) with GameKit multiplayer
- **FamousPeersTVOS**: tvOS app for Apple TV (game host) with MultipeerConnectivity

## Features

✅ 100-card database with per-member point values
✅ GameKit multiplayer (iOS-to-iOS peer-to-peer)
✅ MultipeerConnectivity (tvOS host + iOS clients)
✅ Answer validation with fuzzy matching (typos, partial names)
✅ Sound effects and haptic feedback
✅ Smooth animations (popIn, slideIn, fadeIn, pulse)
✅ Settings UI with audio/haptics toggles
✅ Game rules and difficulty explanations
✅ Real-time scoreboard with live updates
✅ Final leaderboard with medals
✅ tvOS host mode with 30-second answer timeout

## Project Structure

```
famous-peers/
├── FamousPeersCore/              # Shared Swift Package
│   ├── Sources/FamousPeersCore/
│   │   ├── Models/               # Data models, animations, sound
│   │   ├── GameLogic/            # Game engine, networking, managers
│   │   ├── Validation/           # Answer checking
│   │   └── Resources/            # 100-card database (JSON)
│   └── Package.swift
├── FamousPeersIOS/               # iOS app
│   ├── FamousPeersIOS/           # SwiftUI views
│   ├── project.yml               # xcodegen config
│   └── Package.swift
├── FamousPeersTVOS/              # tvOS app
│   ├── FamousPeersTVOS/          # SwiftUI views
│   ├── project.yml               # xcodegen config
│   └── Package.swift
├── scripts/
│   └── generate-projects.sh      # Helper script
├── DEVELOPMENT.md                # Comprehensive dev guide
├── XCODEGEN.md                   # xcodegen setup guide
└── README.md
```

## Documentation

- **[DEVELOPMENT.md](DEVELOPMENT.md)** - Complete architecture, features, and development guide
- **[XCODEGEN.md](XCODEGEN.md)** - xcodegen setup and project generation

## Building

### iOS

```bash
cd FamousPeersIOS
xcodebuild -scheme FamousPeersIOS -destination 'platform=iOS Simulator,name=iPhone 15'
```

### tvOS

```bash
cd FamousPeersTVOS
xcodebuild -scheme FamousPeersTVOS -destination 'platform=tvOS Simulator,name=Apple TV'
```

## Game Flow

1. **Menu**: Select difficulty (Easy/Medium/Hard/Mixed)
2. **Setup**: Enter player names
3. **Playing**: 
   - Show duo name (e.g., "Simon & Garfunkel")
   - Read random member aloud (e.g., "Paul Simon")
   - Guesser names the other member (e.g., "Art Garfunkel")
   - Points awarded based on member fame
   - Auto-advance to next round
4. **Results**: Final leaderboard with medals

## Multiplayer Modes

### iOS-to-iOS (GameKit)
- Player 1 initiates matchmaking
- GameKit finds Player 2
- Both connect via peer-to-peer
- Game logic runs locally on both devices

### tvOS Host + iOS Clients (MultipeerConnectivity)
- tvOS app starts in host mode
- iOS devices browse and connect
- tvOS broadcasts round start (duo name, read member, guesser name)
- iOS devices submit answers
- tvOS validates and broadcasts result
- tvOS auto-advances after 30 seconds

## Requirements

- Xcode 15+
- iOS 16+ deployment target
- tvOS 16+ deployment target
- Swift 5.9+

## Repository

GitHub: https://github.com/djpadz-openclaw-repos/famous-peers
