# Getting Started with Famous Pears

## Quick Start (5 minutes)

### 1. Clone the Repository
```bash
git clone https://github.com/djpadz-openclaw-repos/famous-pears.git
cd famous-pears
```

### 2. Open in Xcode
```bash
open FamousPearsIOS/FamousPearsIOS.xcodeproj
```

### 3. Run on Simulator
- Select iPhone 15 simulator
- Press Cmd+R to build and run

### 4. Play a Game
1. Enter your player name
2. Select game mode (Mixed, Easy, Medium, Hard, or Expert)
3. Wait for other players to join (or test with multiple simulators)
4. Start the game and guess the famous duos!

## Two-Player Setup (Local Network)

### iPhone to iPhone (GameKit)
1. Run the app on two physical iPhones
2. Both players enter their names
3. Select "iPhone to iPhone" mode
4. One player starts matchmaking
5. Other player accepts the match
6. Game begins automatically

### With Apple TV (MultipeerConnectivity)
1. Run tvOS app on Apple TV simulator or device
2. Run iOS app on iPhone simulator or device
3. iOS player selects "With Apple TV" mode
4. tvOS host automatically discovers and connects
5. Game begins when host starts

## Game Modes Explained

### Mixed (Default)
- Random difficulty from all 110 cards
- Points vary by difficulty (1-5)
- Best for variety and challenge

### Easy
- Only 1-point cards
- Longer time limits (45 seconds)
- Great for learning

### Medium
- Only 2-point cards
- 40-second time limit
- Balanced difficulty

### Hard
- Only 3-point cards
- 35-second time limit
- For experienced players

### Expert
- Only 5-point cards
- 25-second time limit
- Maximum challenge

## Understanding Your Stats

### Win Rate
- Percentage of games you've won
- Higher is better

### Accuracy
- Percentage of correct answers submitted
- Reflects your knowledge of famous duos

### Current Win Streak
- How many games in a row you've won
- Resets when you lose

### Longest Win Streak
- Your best consecutive wins
- Never resets

### Average Score
- Your typical score per game
- Useful for tracking improvement

## Tips for Winning

1. **Know Your Categories**: Duos span music, movies, TV, history, sports, and more
2. **Fuzzy Matching**: The game accepts partial names and typos
3. **Time Management**: Harder difficulties have shorter time limits
4. **Consistency**: Play regularly to build win streaks
5. **Learn Patterns**: Certain categories appear more frequently

## Troubleshooting

### Game Won't Connect
- Ensure both devices are on the same Wi-Fi network
- Check that Bluetooth is enabled
- Restart the app and try again

### Stats Not Saving
- Check that the app has permission to access Documents
- Ensure sufficient storage space on device
- Try clearing app cache and restarting

### Sound Not Working
- Check device volume is not muted
- Verify "Sound Effects" is enabled in Settings
- Restart the app

### Slow Performance
- Close other apps running in background
- Reduce simulator count if testing multiple players
- Restart Xcode and simulators

## Development

### Adding New Cards
Edit `FamousPearsCore/Sources/FamousPearsCore/Resources/cards.json`:
```json
{
  "id": 111,
  "category": "music",
  "member1": "Clue Name",
  "member2": "Answer Name",
  "difficulty": 3,
  "hint": "Optional hint"
}
```

### Customizing Game Settings
Edit `MultiplayerGameManager` initialization:
```swift
let manager = MultiplayerGameManager(
    displayName: "Player Name",
    networkMode: .gameKit,
    totalRounds: 5  // Change number of rounds
)
```

### Modifying UI
- iOS: Edit `FamousPearsIOS/FamousPearsIOS/ContentView.swift`
- tvOS: Edit `FamousPearsTVOS/FamousPearsTVOS/TVContentView.swift`

## Support & Feedback

- Report bugs on GitHub Issues
- Suggest features via GitHub Discussions
- Check existing issues before reporting

## Next Steps

- [ ] Play your first game
- [ ] Check your stats on the leaderboard
- [ ] Try different game modes
- [ ] Invite friends to play
- [ ] Build a win streak!
