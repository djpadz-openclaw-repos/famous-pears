import SwiftUI
import FamousPeersCore
import GameKit

struct ContentView: View {
    @State private var gameState: GameFlowState = .menu
    @State private var selectedDifficulty: DifficultyMode = .mixed
    @State private var gameLogic: GameLogic?
    @State private var playerName: String = ""
    @State private var gameMode: GameMode = .computer
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            switch gameState {
            case .menu:
                MainMenuView(
                    showSettings: $showSettings,
                    onStart: { gameState = .modeSelection }
                )
                .slideIn(from: .leading)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .modeSelection:
                GameModeSelectionView(
                    selectedDifficulty: $selectedDifficulty,
                    gameMode: $gameMode,
                    onComputerStart: startGameVsComputer,
                    onMultiplayerStart: startGameVsPlayer,
                    onBack: { gameState = .menu }
                )
                .slideIn(from: .trailing)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .multiplayerMatchmaking:
                VStack {
                    Text("Multiplayer Coming Soon")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .playing:
                if let game = gameLogic {
                    GamePlayView(
                        gameLogic: game,
                        onGameEnd: { gameState = .results }
                    )
                    .slideIn(from: .trailing)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
            case .results:
                if let game = gameLogic {
                    ResultsView(
                        leaderboard: game.getLeaderboard().map { $0.player },
                        onPlayAgain: { gameState = .menu },
                        onExit: { gameState = .menu }
                    )
                    .slideIn(from: .trailing)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            
            if showSettings {
                SettingsView()
                    .transition(.move(edge: .trailing))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            loadPlayerNameFromGameKit()
        }
    }
    
    private func loadPlayerNameFromGameKit() {
        playerName = GKLocalPlayer.local.displayName
    }
    
    private func startGameVsComputer() {
        let player = Player(name: playerName)
        let computerPlayer = Player(name: "Computer")
        let game = GameLogic(players: [player, computerPlayer], difficulty: selectedDifficulty)
        game.startGame()
        gameLogic = game
        gameState = .playing
    }
    
    private func startGameVsPlayer() {
        gameState = .multiplayerMatchmaking
    }
    
    private func handleMatchFound(_ match: GKMatch) {
        let player = Player(name: playerName)
        let remotePlayer = Player(name: match.players.first?.displayName ?? "Opponent")
        let game = GameLogic(players: [player, remotePlayer], difficulty: selectedDifficulty)
        game.startGame()
        gameLogic = game
        gameState = .playing
    }
}

enum GameFlowState {
    case menu
    case modeSelection
    case multiplayerMatchmaking
    case playing
    case results
}

enum GameMode {
    case computer
    case multiplayer
}

// MARK: - Main Menu View

private struct MainMenuView: View {
    @Binding var showSettings: Bool
    var onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("Famous Peers")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
                
                Text("Guess the famous duo!")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            .popIn()
            
            Spacer()
            
            Button(action: onStart) {
                Text("Start Game")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .popIn()
            
            Button(action: { showSettings = true }) {
                Text("Settings")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .foregroundColor(.primary)
                    .cornerRadius(8)
            }
            .popIn()
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Game Mode Selection View

private struct GameModeSelectionView: View {
    @Binding var selectedDifficulty: DifficultyMode
    @Binding var gameMode: GameMode
    var onComputerStart: () -> Void
    var onMultiplayerStart: () -> Void
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
                Text("Player: ")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            
            Text("Select Difficulty")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach([DifficultyMode.easy, .medium, .hard, .mixed], id: \.self) { difficulty in
                    Button(action: { selectedDifficulty = difficulty }) {
                        HStack {
                            Text(difficultyName(difficulty))
                                .font(.headline)
                            Spacer()
                            if selectedDifficulty == difficulty {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(selectedDifficulty == difficulty ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                    }
                }
            }
            .padding()
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: onComputerStart) {
                    Text("Play vs Computer")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: onMultiplayerStart) {
                    Text("Play vs Another Player")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
    
    private func difficultyName(_ difficulty: DifficultyMode) -> String {
        switch difficulty {
        case .easy: return "Easy (1-2 pts)"
        case .medium: return "Medium (2-3 pts)"
        case .hard: return "Hard (3-5 pts)"
        case .mixed: return "Mixed (All)"
        }
    }
}

#Preview {
    ContentView()
}
