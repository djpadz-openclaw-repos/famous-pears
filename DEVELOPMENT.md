# Famous Pears - Development Guide

## Project Overview

Famous Pears is a multiplayer iOS/tvOS game where players guess famous duos based on one member's name. The game supports both local play (iOS-to-iOS via GameKit) and distributed play (iOS devices connecting to a tvOS host via MultipeerConnectivity).

## What's Built

### Core Framework (FamousPearsCore)

**Models**
- `Duo`: Card data (id, category, member1, member2, difficulty, hint)
- `Player`: Game participant with UUID and score tracking
- `GameRound`: Round state (asker, guesser, clue, answer, correctness, points)
- `GameState`: Enum for game flow (setup, playing, roundComplete, gameOver)
- `DifficultyMode`: Enum with point ranges (easy 1-2, medium 2-3, hard 4-5, mixed all)

**Game Logic**
- `GameLogic`: Core engine handling turn management, scoring, round flow, difficulty filtering
- `CardDatabase`: Loads 100 duos from JSON, filters by difficulty
- `Validator`: Answer checking with fuzzy matching (Levenshtein distance, partial name matching, case-insensitive)

**Networking**
- `GameKitManager`: iOS-to-iOS multiplayer via GameKit (matchmaking, peer-to-peer messaging)
- `MultipeerManager`: tvOS/iOS connectivity via MultipeerConnectivity (host/client modes)
- `NetworkGameCoordinator`: Routes messages between GameKit and MultipeerConnectivity, broadcasts game state
- `GameMessage`: Codable protocol for network communication (roundStarted, answerSubmitted, roundResult, gameEnded, etc.)

**Audio & Haptics**
- `SoundManager`: System sounds for correct/incorrect/round start/game end
- Haptic feedback (success/error/light impact) on all game events

**Animations**
- `popIn`: Scale from 0.5 with spring animation
- `slideIn`: Slide from edge with easeInOut
- `fadeIn`: Opacity fade
- `pulse`: Repeating opacity pulse for attention

**Card Database**
- 100 duos across categories: Music, Movies, Tech, History, Concepts
- Difficulty ratings 1-5 (determines points awarded)
- Hints for each duo

### iOS App (FamousPearsIOS)

**Views**
- `ContentView`: Main navigation and game flow state machine
- `DifficultySelectionView`: Difficulty picker with settings button
- `GameSetupView`: Player name entry
- `GamePlayView`: Active game with answer submission, result feedback, scoreboard
- `ResultsView`: Final leaderboard with medals and winner highlight
- `SettingsView`: Sound/haptics toggles, game rules
- `GameRulesView`: How to play guide with difficulty explanations

**Features**
- Difficulty selection (Easy/Medium/Hard/Mixed)
- Player name customization
- Real-time scoreboard with animations
- Answer submission with immediate feedback
- Sound effects and haptic feedback
- Network message handling for multiplayer
- Settings for audio/haptics control

### tvOS App (FamousPearsTVOS)

**Views**
- `TVContentView`: Main navigation and game state machine
- `TVMenuView`: Large-screen difficulty selection (80pt+ text)
- `TVDifficultyButton`: Difficulty picker optimized for tvOS
- `TVHostingView`: Player connection display, ready-to-start button
- `TVGameView`: Active game with clue display (96pt font), answer timeout (30s), result broadcast
- `TVResultsView`: Final leaderboard with medals
- `TVLeaderboardRow`: Ranked player display with medals

**Features**
- Host mode with MultipeerConnectivity
- Large-screen optimized UI (all text 32pt+)
- 30-second answer timeout with auto-advance
- Real-time answer submission from connected iOS devices
- Result broadcasting to all players
- Cyan/yellow color scheme for TV visibility
- Network icon indicator when connected

## Architecture

```
FamousPearsCore (Swift Package)
├── Models/
│   ├── Models.swift (Duo, Player, GameRound, GameState, DifficultyMode)
│   ├── CardDatabase.swift (JSON loader, filtering)
│   ├── GameMessage.swift (Network protocol)
│   ├── Animations.swift (popIn, slideIn, fadeIn, pulse)
│   └── SoundManager.swift (Audio & haptics)
├── GameLogic/
│   ├── GameLogic.swift (Core engine)
│   ├── GameKitManager.swift (iOS multiplayer)
│   ├── MultipeerManager.swift (tvOS/iOS connectivity)
│   └── NetworkGameCoordinator.swift (Message routing)
├── Validation/
│   └── Validator.swift (Answer checking with fuzzy matching)
└── Resources/
    └── cards.json (100 duos)

FamousPearsIOS
├── FamousPearsApp.swift
├── ContentView.swift (Menu + Setup)
├── GamePlayView.swift (Active game)
├── ResultsView.swift (Leaderboard)
└── SettingsView.swift (Settings + Rules)

FamousPearsTVOS
├── FamousPearsTVApp.swift
├── TVContentView.swift (Menu + Setup)
└── TVGameView.swift (Active game + Results)
```

## Multiplayer Flow

### iOS-to-iOS (GameKit)
1. Player 1 initiates matchmaking
2. GameKit finds Player 2
3. Both connect via peer-to-peer
4. Game logic runs locally on both devices
5. Answers sync via GameMessage protocol

### tvOS Host + iOS Clients (MultipeerConnectivity)
1. tvOS app starts in host mode
2. iOS devices browse and connect
3. tvOS broadcasts round start (clue, guesser name)
4. iOS devices submit answers
5. tvOS validates and broadcasts result
6. tvOS auto-advances after 30 seconds or when all players answer

## Game Flow

1. **Menu**: Select difficulty (Easy/Medium/Hard/Mixed)
2. **Setup**: Enter player names
3. **Playing**: 
   - Host (tvOS) displays clue
   - Guesser (iOS) submits answer
   - Result shown with points awarded
   - Auto-advance to next round
4. **Results**: Final leaderboard with medals

## Difficulty Modes

- **Easy**: 1-2 point duos (easier guesses, lower risk)
- **Medium**: 2-3 point duos (moderate difficulty)
- **Hard**: 4-5 point duos (challenging, high reward)
- **Mixed**: All difficulties (varied gameplay)

## Building

### Prerequisites
- Xcode 15+
- iOS 16+ deployment target
- tvOS 16+ deployment target
- Swift 5.9+

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

## Features Implemented

✅ Difficulty-based scoring (1-5 points)
✅ GameKit multiplayer (iOS-to-iOS)
✅ MultipeerConnectivity (tvOS host + iOS clients)
✅ Network message protocol (GameMessage)
✅ Answer validation with fuzzy matching
✅ Sound effects (correct/incorrect/round start/game end)
✅ Haptic feedback (success/error/light impact)
✅ Animations (popIn, slideIn, fadeIn, pulse)
✅ Settings UI (sound/haptics toggles)
✅ Game rules view
✅ 100-card database with categories
✅ tvOS host mode with 30-second timeout
✅ Real-time scoreboard updates
✅ Final leaderboard with medals
✅ Large-screen tvOS UI (32pt+ text)

## Known Limitations

- GameMessage leaderboard encoding uses intermediate dict format (could be optimized)
- No reconnection logic if connection drops mid-game
- No timeout handling for slow networks
- Answer validation is local (no server-side verification)
- No persistent game history or statistics
- No player profiles or achievements
- No custom card sets

## Next Steps (Future Enhancements)

1. **Persistence**
   - Save game history
   - Track player statistics (win rate, average score)
   - Leaderboard across sessions

2. **Enhanced Gameplay**
   - Streak tracking
   - Challenge/dispute system
   - Category hints during gameplay
   - Difficulty hints (e.g., "This is a musician")
   - Timed rounds with countdown

3. **Social Features**
   - Player profiles
   - Friend invites
   - Replay sharing
   - Social media integration

4. **Content**
   - More card categories
   - User-submitted duos
   - Seasonal card sets
   - Themed collections

5. **Polish**
   - Background music option
   - Custom themes
   - Accessibility improvements
   - Localization

6. **Testing**
   - Unit tests for GameLogic
   - Validator edge cases
   - Network failure scenarios
   - Multiplayer stress testing

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

- **id**: Unique identifier (1-100)
- **category**: music, movies, tech, history, concepts
- **member1**: The clue shown to the guesser
- **member2**: The answer to guess
- **difficulty**: 1-5 (determines points awarded)
- **hint**: Context for the duo

## Deployment

### iOS
1. Create Apple Developer account
2. Set up provisioning profiles
3. Configure signing in Xcode
4. Build for App Store or TestFlight
5. Submit for review

### tvOS
1. Same process as iOS
2. Ensure tvOS 16+ compatibility
3. Test on actual Apple TV hardware
4. Submit to App Store

## Performance Notes

- Card database loads once at app startup
- Network messages are JSON-encoded (could use Protocol Buffers for optimization)
- Animations use SwiftUI's native rendering (efficient)
- No heavy computation (validation is O(n) string operations)
- Memory footprint is minimal (~5MB for 100 cards + UI)

## Testing Checklist

- [ ] Single-player game flow (all difficulties)
- [ ] iOS-to-iOS multiplayer (GameKit)
- [ ] tvOS host + iOS clients (MultipeerConnectivity)
- [ ] Answer validation (exact, partial, typos)
- [ ] Sound effects (all events)
- [ ] Haptic feedback (all events)
- [ ] Settings toggles (sound/haptics)
- [ ] Leaderboard accuracy
- [ ] Network message routing
- [ ] tvOS 30-second timeout
- [ ] Results screen display
- [ ] Difficulty filtering

## Repository

GitHub: https://github.com/djpadz-openclaw-repos/famous-pears

Main branches:
- `main`: Production-ready code
- Feature branches for new features

## License

MIT (or specify your preferred license)
