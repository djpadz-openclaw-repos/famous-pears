import SwiftUI
import FamousPeersCore

struct TVContentView: View {
    @State private var gameState: TVGameState = .menu
    @State private var selectedDifficulty: DifficultyMode = .mixed
    @State private var gameLogic: GameLogic?
    @State private var players: [Player] = [
        Player(name: "Player 1"),
        Player(name: "Player 2")
    ]
    @EnvironmentObject var multipeerManager: MultipeerManager
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Group {
                switch gameState {
                case .menu:
                    TVMenuView(
                        selectedDifficulty: $selectedDifficulty,
                        onStart: { gameState = .hosting }
                    )
                    
                case .hosting:
                    TVHostingView(
                        difficulty: selectedDifficulty,
                        onPlayersReady: startGame,
                        onBack: { gameState = .menu }
                    )
                    
                case .playing:
                    if let game = gameLogic {
                        TVGameView(
                            gameLogic: game,
                            onGameEnd: { gameState = .results }
                        )
                    }
                    
                case .results:
                    if let game = gameLogic {
                        TVResultsView(
                            leaderboard: game.getLeaderboard(),
                            onPlayAgain: { gameState = .menu }
                        )
                    }
                }
            }
        }
        .onAppear {
            multipeerManager.startAsHost()
        }
    }
    
    private func startGame() {
        let game = GameLogic(players: players, difficulty: selectedDifficulty)
        game.startGame()
        gameLogic = game
        gameState = .playing
    }
}

enum TVGameState {
    case menu
    case hosting
    case playing
    case results
}

struct TVMenuView: View {
    @Binding var selectedDifficulty: DifficultyMode
    var onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 60) {
            VStack(spacing: 16) {
                Text("Famous Pears")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.cyan)
                
                Text("Guess the famous duo!")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
            }
            .popIn()
            
            VStack(spacing: 24) {
                Text("Select Difficulty")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 20) {
                    ForEach([DifficultyMode.easy, .medium, .hard, .mixed], id: \.self) { difficulty in
                        TVDifficultyButton(
                            difficulty: difficulty,
                            isSelected: selectedDifficulty == difficulty,
                            action: { selectedDifficulty = difficulty }
                        )
                    }
                }
            }
            .padding(40)
            .background(Color.white.opacity(0.05))
            .cornerRadius(20)
            
            Button(action: onStart) {
                Text("Start Hosting")
                    .font(.system(size: 40, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .background(Color.cyan)
                    .foregroundColor(.black)
                    .cornerRadius(16)
            }
            .popIn()
            
            Spacer()
        }
        .padding(60)
    }
}

struct TVDifficultyButton: View {
    let difficulty: DifficultyMode
    let isSelected: Bool
    let action: () -> Void
    
    var difficultyName: String {
        switch difficulty {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .mixed: return "Mixed"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(difficultyName)
                    .font(.system(size: 32, weight: .semibold))
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(isSelected ? Color.cyan.opacity(0.3) : Color.white.opacity(0.1))
            .foregroundColor(isSelected ? .cyan : .white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.cyan : Color.clear, lineWidth: 3)
            )
        }
    }
}

struct TVHostingView: View {
    let difficulty: DifficultyMode
    var onPlayersReady: () -> Void
    var onBack: () -> Void
    @EnvironmentObject var multipeerManager: MultipeerManager
    
    var body: some View {
        VStack(spacing: 40) {
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 12) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.cyan)
                }
                Spacer()
                Text("Waiting for Players...")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(40)
            
            VStack(spacing: 24) {
                Text("Connected Players: \(multipeerManager.connectedPeers.count)")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.white)
                
                ForEach(multipeerManager.connectedPeers, id: \.self) { peer in
                    HStack {
                        Image(systemName: "person.fill")
                            .font(.system(size: 28))
                        Text(peer.displayName)
                            .font(.system(size: 32, weight: .semibold))
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.green)
                    }
                    .padding(24)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 40)
                }
            }
            .padding(40)
            .background(Color.white.opacity(0.05))
            .cornerRadius(20)
            
            if multipeerManager.connectedPeers.count >= 1 {
                Button(action: onPlayersReady) {
                    Text("Start Game")
                        .font(.system(size: 40, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .background(Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(16)
                }
                .padding(40)
                .slideIn(from: .bottom)
            }
            
            Spacer()
        }
    }
}



struct TVResultsView: View {
    let leaderboard: [Player]
    var onPlayAgain: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 20) {
                Text("Game Over!")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.cyan)
                
                Text("Final Scores")
                    .font(.system(size: 44))
                    .foregroundColor(.gray)
            }
            .popIn()
            
            VStack(spacing: 24) {
                ForEach(Array(leaderboard.enumerated()), id: \.element.id) { index, player in
                    TVLeaderboardRow(rank: index + 1, player: player, isWinner: index == 0)
                        .slideIn(from: .leading)
                }
            }
            .padding(40)
            .background(Color.white.opacity(0.05))
            .cornerRadius(20)
            
            Button(action: onPlayAgain) {
                Text("Play Again")
                    .font(.system(size: 40, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .background(Color.green)
                    .foregroundColor(.black)
                    .cornerRadius(16)
            }
            .padding(40)
            .slideIn(from: .bottom)
            
            Spacer()
        }
        .padding(60)
        .background(Color.black.ignoresSafeArea())
    }
}

struct TVLeaderboardRow: View {
    let rank: Int
    let player: Player
    let isWinner: Bool
    
    var medalEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "•"
        }
    }
    
    var body: some View {
        HStack(spacing: 32) {
            Text(medalEmoji)
                .font(.system(size: 56))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(player.name)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.white)
                
                if isWinner {
                    Text("Winner!")
                        .font(.system(size: 28))
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
            
            Text("\(player.score) pts")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(isWinner ? .green : .cyan)
        }
        .padding(32)
        .background(isWinner ? Color.green.opacity(0.1) : Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isWinner ? Color.green : Color.clear, lineWidth: 3)
        )
    }
}

#Preview {
    TVContentView()
        .environmentObject(MultipeerManager.shared)
}
