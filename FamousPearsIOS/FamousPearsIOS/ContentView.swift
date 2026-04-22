import SwiftUI
import FamousPearsCore
import GameKit

struct ContentView: View {
    @State private var gameManager: MultiplayerGameManager?
    @State private var gameKitManager: GameKitManager?
    @State private var playerName = ""
    @State private var gameMode: GameMode = .gameKit
    @State private var showGameSetup = false
    
    enum GameMode {
        case gameKit
        case multipeer
    }
    
    var body: some View {
        NavigationStack {
            if let manager = gameManager {
                GameFlowView(gameManager: manager)
            } else if gameMode == .gameKit && gameKitManager != nil {
                GameKitMatchmakingView(
                    gameKitManager: gameKitManager!,
                    playerName: playerName,
                    onMatchFound: startGameWithMatch
                )
            } else {
                MainMenuView(
                    playerName: $playerName,
                    gameMode: $gameMode,
                    onStartGame: startGame
                )
            }
        }
    }
    
    private func startGame() {
        guard !playerName.isEmpty else { return }
        
        if gameMode == .gameKit {
            // Initialize GameKit manager and start matchmaking
            let gkManager = GameKitManager()
            gameKitManager = gkManager
            
            // Start matchmaking after a brief delay to ensure manager is set up
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                gkManager.startMatchmaking(minPlayers: 2, maxPlayers: 4)
            }
        } else {
            // Multipeer mode - create game manager directly
            let networkMode: NetworkCoordinator.NetworkMode = .multipeer(isHost: false)
            let manager = MultiplayerGameManager(displayName: playerName, networkMode: networkMode, totalRounds: 5)
            gameManager = manager
        }
    }
    
    private func startGameWithMatch() {
        guard let gkManager = gameKitManager else { return }
        
        let networkMode: NetworkCoordinator.NetworkMode = .gameKit
        let manager = MultiplayerGameManager(displayName: playerName, networkMode: networkMode, totalRounds: 5)
        gameManager = manager
        gameKitManager = nil
    }
}

struct GameKitMatchmakingView: View {
    @ObservedObject var gameKitManager: GameKitManager
    let playerName: String
    var onMatchFound: () -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Finding Match")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Waiting for opponent...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                ProgressView()
                    .scaleEffect(1.5)
                
                if let error = gameKitManager.error {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.red)
                        Text("Error")
                            .fontWeight(.bold)
                        Text(error)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            
            // Present GKMatchmakerViewController if available
            if let matchmakerVC = gameKitManager.matchmakerViewController {
                GameKitMatchmakerContainer(viewController: matchmakerVC)
                    .ignoresSafeArea()
            }
        }
        .onChange(of: gameKitManager.matchStarted) { oldValue, newValue in
            if newValue {
                onMatchFound()
            }
        }
    }
}

struct GameKitMatchmakerContainer: UIViewControllerRepresentable {
    let viewController: UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}

struct MainMenuView: View {
    @Binding var playerName: String
    @Binding var gameMode: ContentView.GameMode
    var onStartGame: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Famous Pears")
                    .font(.system(size: 48, weight: .bold))
                Text("Guess the Famous Duo")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            .padding(.top, 40)
            
            VStack(spacing: 16) {
                TextField("Enter your name", text: $playerName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    Text("Game Mode")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    Picker("Mode", selection: $gameMode) {
                        Text("iPhone to iPhone").tag(ContentView.GameMode.gameKit)
                        Text("With Apple TV").tag(ContentView.GameMode.multipeer)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding()
            
            Button(action: onStartGame) {
                Text("Start Game")
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .font(.headline)
            }
            .padding()
            .disabled(playerName.isEmpty)
            
            Spacer()
        }
    }
}

struct GameFlowView: View {
    @ObservedObject var gameManager: MultiplayerGameManager
    @State private var answerText = ""
    @State private var showAnswerSubmitted = false
    
    var body: some View {
        ZStack {
            switch gameManager.gamePhase {
            case .waiting:
                WaitingForPlayersView(gameManager: gameManager)
            case .starting:
                StartingGameView(gameManager: gameManager)
            case .roundActive:
                ActiveRoundView(
                    gameManager: gameManager,
                    answerText: $answerText,
                    onSubmit: submitAnswer
                )
            case .roundEnded:
                RoundEndedView(gameManager: gameManager)
            case .gameEnded:
                GameEndedView(gameManager: gameManager)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func submitAnswer() {
        guard !answerText.isEmpty else { return }
        Task {
            await gameManager.submitAnswer(answerText)
            answerText = ""
            showAnswerSubmitted = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showAnswerSubmitted = false
            }
        }
    }
}

struct WaitingForPlayersView: View {
    @ObservedObject var gameManager: MultiplayerGameManager
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Waiting for Players")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                ForEach(gameManager.players) { player in
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                        Text(player.name)
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding()
            
            Text("\(gameManager.players.count) player\(gameManager.players.count == 1 ? "" : "s") joined")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            if gameManager.players.count >= 2 {
                Button(action: startGame) {
                    Text("Start Game")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func startGame() {
        Task {
            await gameManager.startGame()
        }
    }
}

struct StartingGameView: View {
    @ObservedObject var gameManager: MultiplayerGameManager
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Get Ready!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Game starting in 3 seconds...")
                .font(.headline)
                .foregroundColor(.gray)
            
            ProgressView()
                .scaleEffect(1.5)
            
            Spacer()
        }
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                Task {
                    await gameManager.startRound()
                }
            }
        }
    }
}

struct ActiveRoundView: View {
    @ObservedObject var gameManager: MultiplayerGameManager
    @Binding var answerText: String
    var onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Round \(gameManager.currentRound)/\(gameManager.totalRounds)")
                    .font(.headline)
                Spacer()
                Text("Difficulty: ⭐ × \(gameManager.gameState.currentRound.difficulty)")
                    .font(.subheadline)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            
            VStack(spacing: 16) {
                Text("Who is the famous pair?")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(gameManager.gameState.currentRound.clue)
                    .font(.system(size: 36, weight: .bold))
                    .padding()
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(12)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
            }
            
            VStack(spacing: 12) {
                TextField("Enter your answer", text: $answerText)
                    .textFieldStyle(.roundedBorder)
                    .font(.headline)
                
                Button(action: onSubmit) {
                    Text("Submit Answer")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .fontWeight(.semibold)
                }
                .disabled(answerText.isEmpty)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Scores")
                    .font(.headline)
                    .padding(.horizontal)
                
                ForEach(gameManager.players) { player in
                    HStack {
                        Text(player.name)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(gameManager.players.firstIndex(where: { $0.id == player.id }).map { String(gameManager.players[$0].score) } ?? "0") pts")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            Spacer()
        }
        .padding()
    }
}

struct RoundEndedView: View {
    @ObservedObject var gameManager: MultiplayerGameManager
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Round \(gameManager.currentRound) Complete")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("The answer was:")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(gameManager.gameState.currentRound.answer)
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .background(Color.green.opacity(0.2))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Current Scores")
                    .font(.headline)
                
                ForEach(gameManager.players) { player in
                    HStack {
                        Text(player.name)
                        Spacer()
                        Text("\(gameManager.players.firstIndex(where: { $0.id == player.id }).map { String(gameManager.players[$0].score) } ?? "0") pts")
                            .fontWeight(.bold)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            if gameManager.currentRound < gameManager.totalRounds {
                Button(action: nextRound) {
                    Text("Next Round")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func nextRound() {
        Task {
            await gameManager.startRound()
        }
    }
}

struct GameEndedView: View {
    @ObservedObject var gameManager: MultiplayerGameManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Game Over!")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                ForEach(gameManager.players.sorted { a, b in
                    (gameManager.players.firstIndex(where: { $0.id == a.id }).map { gameManager.players[$0].score } ?? 0) >
                    (gameManager.players.firstIndex(where: { $0.id == b.id }).map { gameManager.players[$0].score } ?? 0)
                }) { player in
                    HStack {
                        Text(player.name)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(gameManager.players.firstIndex(where: { $0.id == player.id }).map { String(gameManager.players[$0].score) } ?? "0") pts")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            Button(action: { dismiss() }) {
                Text("Return to Menu")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
