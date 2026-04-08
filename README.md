# Famous Pears - Complete Game

A multiplayer iOS/tvOS game where players guess famous duos based on one member's name. Built with SwiftUI, GameKit, and MultipeerConnectivity.

## Features

### Core Gameplay
- **110 Famous Duos** across 10 categories (music, movies, TV, history, sports, comedy, tech, literature, art, concepts)
- **5 Difficulty Levels** (Easy to Expert) with varying point values and time limits
- **Multiple Game Modes**: Mixed difficulty, Easy-only, Medium-only, Hard-only, Expert-only
- **Real-time Multiplayer**: 2-4 players per game
- **Fuzzy Answer Matching**: Tolerates typos and partial names

### Multiplayer
- **GameKit Support**: iPhone-to-iPhone play via peer-to-peer connectivity
- **MultipeerConnectivity**: tvOS host with iOS players
- **Network Message Protocol**: 9 message types for complete game flow
- **Automatic Reconnection**: Handles player disconnections gracefully

### User Experience
- **Animations**: Spring, fade, slide, pulse, and flip effects
- **Sound Effects**: Procedural audio for correct/incorrect answers, round/game events
- **Stats Tracking**: Win rate, accuracy, streaks, and leaderboards
- **Leaderboard**: Sort by total score, win rate, accuracy, games played, or average score
- **Settings**: Configurable game modes, rounds, sound, and hints

### iOS App
- Player name entry and game mode selection
- Real-time answer submission with validation
- Live score tracking
- Comprehensive leaderboard with player stats
- Settings and preferences

### tvOS App
- Large-screen optimized host interface
- Real-time player connection status
- 30-second countdown timer per round
- Score leaderboard with difficulty indicators
- Game state management for all phases

## Architecture

### FamousPearsCore (Shared Swift Package)
- **Models**: Duo, Player, GameRound, GameState
- **GameLogic**: Turn management, scoring, round flow
- **Validation**: Answer checking with fuzzy matching
- **CardDatabase**: 110 duos with difficulty ratings
- **Multiplayer**: GameKitManager, MultipeerManager, NetworkCoordinator
- **MultiplayerGameManager**: Bridges game logic with networking
- **GameModeManager**: Difficulty filtering and card selection
- **SoundManager**: Procedural audio effects
- **StatsManager**: Game statistics and leaderboards
- **UI Helpers**: Animations and button styles

### FamousPearsIOS
- ContentView: Main menu and game flow
- GameFlowView: Active game state management
- LeaderboardView: Stats and rankings
- SettingsView: Game preferences
- Integrated with MultiplayerGameManager

### FamousPearsTVOS
- TVContentView: Host setup and game hosting
- TVGameHostView: Real-time game display
- Large-screen optimized UI for all game phases

## Building

### Prerequisites
- Xcode 15+
- iOS 16+ deployment target
- tvOS 16+ deployment target
- Swift 5.9+

### Build Commands

**iOS App:**
```bash
cd FamousPearsIOS
xcodebuild -scheme FamousPearsIOS -destination 'platform=iOS Simulator,name=iPhone 15'
```

**tvOS App:**
```bash
cd FamousPearsTVOS
xcodebuild -scheme FamousPearsTVOS -destination 'platform=tvOS Simulator,name=Apple TV'
```

## Game Flow

1. **Setup**: Players enter names and select game mode
2. **Waiting**: Host waits for 2-4 players to connect
3. **Starting**: 3-second countdown before first round
4. **Round Active**: 30-second timer, players submit answers
5. **Round Ended**: Show correct answer and update scores
6. **Game Ended**: Display final leaderboard and stats

## Network Protocol

### Message Types
- `playerJoined`: New player connected
- `playerLeft`: Player disconnected
- `gameStarted`: Game initialization
- `roundStarted`: New round with clue
- `playerAnswer`: Answer submission
- `roundEnded`: Round results and scoring
- `gameEnded`: Final results
- `scoreUpdate`: Score change
- `error`: Error notification

## Stats & Leaderboards

### Tracked Metrics
- Games played and won
- Total and average score
- Correct answers and accuracy
- Win streaks (current and longest)
- Join date and last played date

### Leaderboard Sorting
- Total Score (default)
- Win Rate
- Accuracy
- Games Played
- Average Score

## Card Database

110 famous duos across categories:
- **Music** (15 duos): Beatles, Rolling Stones, Steely Dan, etc.
- **Movies** (15 duos): Batman & Robin, Butch Cassidy, etc.
- **TV** (10 duos): I Love Lucy, Friends, Breaking Bad, etc.
- **History** (10 duos): Romeo & Juliet, Cleopatra & Caesar, etc.
- **Sports** (10 duos): Magic & Bird, Ali & Frazier, etc.
- **Comedy** (5 duos): Cheech & Chong, Penn & Teller, etc.
- **Tech** (10 duos): Jobs & Wozniak, Gates & Allen, etc.
- **Literature** (10 duos): Sherlock & Watson, Harry & Ron, etc.
- **Art** (5 duos): Picasso & Braque, Van Gogh & Gauguin, etc.
- **Concepts** (5 duos): Peanut butter & jelly, Salt & pepper, etc.

## Future Enhancements

- [ ] Cloud sync for stats across devices
- [ ] Daily challenges with bonus points
- [ ] Custom card creation and sharing
- [ ] Voice-based answer submission
- [ ] Achievements and badges
- [ ] Replay system to review past games
- [ ] Difficulty progression system
- [ ] Seasonal leaderboards
- [ ] Social sharing of game results
- [ ] Offline play mode

## License

MIT License - See LICENSE file for details

## Support

For issues, feature requests, or contributions, please visit the GitHub repository.
