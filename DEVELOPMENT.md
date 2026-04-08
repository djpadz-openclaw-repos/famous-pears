# Development Guide

## What's Built

### Core Framework (FamousPearsCore)
- **Models**: Duo, Player, GameRound, GameState, DifficultyMode
- **GameLogic**: Turn management, scoring, round flow, difficulty filtering
- **Validation**: Answer checking with fuzzy matching (typo tolerance, partial name matching, Levenshtein distance)
- **CardDatabase**: 100 duos across music, movies, tech, history, concepts
- **Animations**: popIn, slideIn, fadeIn, pulse effects
- **GameKitManager**: iOS-to-iOS multiplayer via GameKit
- **MultipeerManager**: tvOS/iOS connectivity via MultipeerConnectivity
- **GameMessage**: Network protocol for game state synchronization

### iOS App
- Difficulty selection (Easy/Medium/Hard/Mixed)
- Player name entry
- Game flow: Menu → Setup → Playing → Results
- Live scoreboard with animations
- Answer submission with result feedback
- Leaderboard with medals and winner highlight
- GameKit integration ready for matchmaking

### tvOS App
- Large-screen optimized UI (all text 32pt+)
- Difficulty selection
- Host mode with player connection display
- Live clue display (96pt font)
- Scoreboard with cyan/yellow color scheme
- Results screen with leaderboard

### Card Database
- 100 duos with difficulty ratings (1-5 points)
- Categories: Music, Movies, Tech, History, Concepts
- Hints for each duo
- Difficulty filtering by mode

## Architecture

```
FamousPearsCore (Swift Package)
├── Models/
│   ├── Models.swift (Duo, Player, GameRound, GameState, DifficultyMode)
│   ├── CardDatabase.swift
│   ├── GameMessage.swift
│   └── Animations.swift
├── GameLogic/
│   ├── GameLogic.swift
│   ├── GameKitManager.swift
│   └── MultipeerManager.swift
├── Validation/
│   └── Validator.swift
└── Resources/
    └── cards.json (100 duos)

FamousPearsIOS
├── FamousPearsApp.swift
├── ContentView.swift (Menu + Setup)
├── GamePlayView.swift (Active game)
└── ResultsView.swift (Leaderboard)

FamousPearsTVOS
├── FamousPearsTVApp.swift
└── TVContentView.swift (All screens)
```

## Building

### Prerequisites
- Xcode 15+
- iOS 16+ deployment target
- tvOS 16+ deployment target

### Build iOS
```bash
cd FamousPearsIOS
xcodebuild -scheme FamousPearsIOS -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Build tvOS
```bash
cd FamousPearsTVOS
xcodebuild -scheme FamousPearsTVOS -destination 'platform=tvOS Simulator,name=Apple TV'
```

## Features

### Difficulty Modes
- **Easy**: 1-2 point duos (easier guesses)
- **Medium**: 2-3 point duos (moderate difficulty)
- **Hard**: 4-5 point duos (challenging)
- **Mixed**: All difficulties (varied gameplay)

### Multiplayer
- **iOS-to-iOS**: GameKit matchmaking (peer-to-peer)
- **tvOS Host**: MultipeerConnectivity for iOS devices to connect
- Network protocol for real-time game state sync

### Animations
- Pop-in for important elements
- Slide-in for transitions
- Fade-in for subtle reveals
- Pulse effect for attention

### Scoring
- Points awarded based on duo difficulty
- Correct answers only
- Live leaderboard updates
- Final results with medals

## Next Steps

1. **Wire up multiplayer communication**
   - Implement GameMessage sending/receiving in game views
   - Handle player turn rotation across network
   - Sync scores in real-time

2. **Sound & Haptics**
   - Correct/incorrect answer sounds
   - Haptic feedback on submission
   - Background music option

3. **Enhanced UX**
   - Difficulty hints during gameplay
   - Category display for context
   - Streak tracking
   - Undo/challenge system

4. **Testing**
   - Unit tests for GameLogic
   - Validator edge cases
   - Multiplayer scenarios

5. **Polish**
   - Error handling for network failures
   - Reconnection logic
   - Timeout handling
   - Better loading states

## Known Issues

- GameMessage leaderboard encoding needs refinement
- MultipeerManager needs delegate cleanup on disconnect
- No timeout handling for slow networks
- No reconnection logic if connection drops mid-game

## Card Database Format

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

- **difficulty**: 1 (easy) to 5 (hard) — determines points awarded
- **member1**: The clue shown to the guesser
- **member2**: The answer to guess
- **category**: For filtering/context (not yet used in UI)
