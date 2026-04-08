import SwiftUI
import FamousPeersCore

struct ContentView: View {
    @State private var gameState: GameFlowState = .menu
    @State private var selectedDifficulty: DifficultyMode = .mixed
    @State private var gameLogic: GameLogic?
    @State private var players: [Player] = [
        Player(name: "Player 1"),
        Player(name: "Player 2")
    ]
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Group {
                switch gameState {
                case .menu:
                    DifficultySelectionView(
                        selectedDifficulty: $selectedDifficulty,
                        showSettings: $showSettings,
                        onStart: { gameState = .setup }
                    )
                    .slideIn(from: .leading)
                    
                case .setup:
                    GameSetupView(
                        players: $players,
                        difficulty: selectedDifficulty,
                        onStart: startGame,
                        onBack: { gameState = .menu }
                    )
                    .slideIn(from: .trailing)
                    
                case .playing:
                    if let game = gameLogic {
                        GamePlayView(
                            gameLogic: game,
                            onGameEnd: { gameState = .results }
                        )
                        .slideIn(from: .trailing)
                    }
                    
                case .results:
                    if let game = gameLogic {
                        ResultsView(
                            leaderboard: game.getLeaderboard(),
                            onPlayAgain: { gameState = .menu },
                            onExit: { gameState = .menu }
                        )
                        .slideIn(from: .trailing)
                    }
                }
            }
            
            if showSettings {
                SettingsView()
                    .transition(.move(edge: .trailing))
            }
        }
    }
    
    private func startGame() {
        let game = GameLogic(players: players, difficulty: selectedDifficulty)
        game.startGame()
        gameLogic = game
        gameState = .playing
    }
}

enum GameFlowState {
    case menu
    case setup
    case playing
    case results
}

struct DifficultySelectionView: View {
    @Binding var selectedDifficulty: DifficultyMode
    @Binding var showSettings: Bool
    var onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Famous Pears")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("Guess the famous duo!")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(action: { showSettings = true }) {
                    Image(systemName: "gear")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
            }
            .popIn()
            
            VStack(spacing: 16) {
                Text("Select Difficulty")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                ForEach([DifficultyMode.easy, .medium, .hard, .mixed], id: \.self) { difficulty in
                    DifficultyButton(
                        difficulty: difficulty,
                        isSelected: selectedDifficulty == difficulty,
                        action: { selectedDifficulty = difficulty }
                    )
                    .slideIn(from: .leading)
                }
            }
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(12)
            
            Button(action: onStart) {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .popIn()
            
            Spacer()
        }
        .padding()
    }
}

struct DifficultyButton: View {
    let difficulty: DifficultyMode
    let isSelected: Bool
    let action: () -> Void
    
    var difficultyName: String {
        switch difficulty {
        case .easy: return "Easy (1-2 pts)"
        case .medium: return "Medium (2-3 pts)"
        case .hard: return "Hard (4-5 pts)"
        case .mixed: return "Mixed (All)"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(difficultyName)
                    .font(.headline)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
            .foregroundColor(.primary)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct GameSetupView: View {
    @Binding var players: [Player]
    let difficulty: DifficultyMode
    var onStart: () -> Void
    var onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: onBack) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.blue)
                }
                Spacer()
                Text("Game Setup")
                    .font(.headline)
                Spacer()
            }
            .padding()
            
            VStack(spacing: 12) {
                Text("Player Names")
                    .font(.headline)
                
                ForEach($players) { $player in
                    TextField("Player name", text: $player.name)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                }
            }
            .popIn()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Difficulty: \(difficultyString)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding()
            
            Button(action: onStart) {
                Text("Start Game")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            
            Spacer()
        }
    }
    
    var difficultyString: String {
        switch difficulty {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .mixed: return "Mixed"
        }
    }
}

#Preview {
    ContentView()
}
