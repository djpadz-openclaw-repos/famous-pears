import SwiftUI
import FamousPearsCore

struct TVContentView: View {
    @State private var gameManager: MultiplayerGameManager?
    @State private var hostName = "Apple TV"
    @State private var showSetup = true
    
    var body: some View {
        ZStack {
            if let manager = gameManager {
                TVGameHostView(gameManager: manager)
            } else {
                TVSetupView(hostName: $hostName, onStart: startGame)
            }
        }
        .ignoresSafeArea()
    }
    
    private func startGame() {
        let manager = MultiplayerGameManager(
            displayName: hostName,
            networkMode: .multipeer(isHost: true),
            totalRounds: 5
        )
        gameManager = manager
    }
}

struct TVSetupView: View {
    @Binding var hostName: String
    var onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                Text("Famous Pears")
                    .font(.system(size: 72, weight: .bold))
                Text("Game Host")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 24) {
                Text("Waiting for players to connect...")
                    .font(.system(size: 32))
                
                ProgressView()
                    .scaleEffect(2)
                    .tint(.blue)
            }
            
            Button(action: onStart) {
                Text("Start Game")
                    .font(.system(size: 28, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding(40)
            
            Spacer()
        }
        .padding(60)
        .background(Color.black)
        .foregroundColor(.white)
    }
}

struct TVGameHostView: View {
    @ObservedObject var gameManager: MultiplayerGameManager
    @State private var timeRemaining = 30
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            switch gameManager.gamePhase {
            case .waiting:
                TVWaitingView(gameManager: gameManager)
            case .starting:
                TVStartingView(gameManager: gameManager)
            case .roundActive:
                TVActiveRoundView(
                    gameManager: gameManager,
                    timeRemaining: $timeRemaining
                )
            case .roundEnded:
                TVRoundEndedView(gameManager: gameManager)
            case .gameEnded:
                TVGameEndedView(gameManager: gameManager)
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
}

struct TVWaitingView: View {
    @ObservedObject var gameManager: MultiplayerGameManager
    
    var body: some View {
        VStack(spacing: 60) {
            Text("Waiting for Players")
                .font(.system(size: 56, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 24) {
                ForEach(gameManager.players) { player in
                    HStack(spacing: 24) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        
                        Text(player.name)
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.green)
                    }
                    .padding(32)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(16)
                }
            }
            .padding(40)
            
            Text("\(gameManager.players.count) player\(gameManager.players.count == 1 ? "" : "s") ready")
                .font(.system(size: 32))
                .foregroundColor(.gray)
            
            if gameManager.players.count >= 2 {
                Button(action: startGame) {
                    Text("Start Game")
                        .font(.system(size: 36, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(32)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .padding(40)
            }
            
            Spacer()
        }
        .padding(60)
    }
    
    private func startGame() {
        Task {
            await gameManager.startGame()
        }
    }
}

struct TVStartingView: View {
    @ObservedObject var gameManager: MultiplayerGameManager
    @State private var countdown = 3
    
    var body: some View {
        VStack(spacing: 60) {
            Text("Get Ready!")
                .font(.system(size: 72, weight: .bold))
                .foregroundColor(.white)
            
            Text("\(countdown)")
                .font(.system(size: 120, weight: .bold))
                .foregroundColor(.blue)
                .monospacedDigit()
            
            Spacer()
        }
        .padding(60)
        .onAppear {
            startCountdown()
        }
    }
    
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            countdown -= 1
            if countdown <= 0 {
                timer.invalidate()
                Task {
                    await gameManager.startRound()
                }
            }
        }
    }
}

struct TVActiveRoundView: View {
    @ObservedObject var gameManager: MultiplayerGameManager
    @Binding var timeRemaining: Int
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 40) {
            HStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Round \(gameManager.currentRound)/\(gameManager.totalRounds)")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    Text("Difficulty")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 8) {
                        ForEach(0..<gameManager.gameState.currentRound.difficulty, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.yellow)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 12) {
                    Text("Time Remaining")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    
                    Text("\(timeRemaining)s")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundColor(timeRemaining <= 10 ? .red : .white)
                        .monospacedDigit()
                }
            }
            .padding(40)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
            
            VStack(spacing: 24) {
                Text("Who is the famous pair?")
                    .font(.system(size: 32))
                    .foregroundColor(.gray)
                
                Text(gameManager.gameState.currentRound.clue)
                    .font(.system(size: 96, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .minimumScaleFactor(0.5)
                    .padding(40)
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(24)
            }
            
            VStack(spacing: 16) {
                Text("Scores")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(gameManager.players.sorted { a, b in
                    (gameManager.players.firstIndex(where: { $0.id == a.id }).map { gameManager.players[$0].score } ?? 0) >
                    (gameManager.players.firstIndex(where: { $0.id == b.id }).map { gameManager.players[$0].score } ?? 0)
                }) { player in
                    HStack(spacing: 24) {
                        Text(player.name)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(gameManager.players.firstIndex(where: { $0.id == player.id }).map { String(gameManager.players[$0].score) } ?? "0") pts")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    .padding(20)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding(40)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(16)
            
            Spacer()
        }
        .padding(60)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startTimer() {
        timeRemaining = 30
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timeRemaining -= 1
            if timeRemaining <= 0 {
                timer?.invalidate()
                Task {
                    await gameManager.endRound()
                }
            }
        }
    }
}

struct TVRoundEndedView: View {
    @ObservedObject var gameManager: MultiplayerGameManager
    
    var body: some View {
        VStack(spacing: 60) {
            Text("Round \(gameManager.currentRound) Complete")
                .font(.system(size: 56, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 24) {
                Text("The answer was:")
                    .font(.system(size: 32))
                    .foregroundColor(.gray)
                
                Text(gameManager.gameState.currentRound.answer)
                    .font(.system(size: 72, weight: .bold))
                    .foregroundColor(.white)
                    .padding(40)
                    .background(Color.green.opacity(0.3))
                    .cornerRadius(24)
            }
            
            VStack(spacing: 16) {
                Text("Current Scores")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(gameManager.players.sorted { a, b in
                    (gameManager.players.firstIndex(where: { $0.id == a.id }).map { gameManager.players[$0].score } ?? 0) >
                    (gameManager.players.firstIndex(where: { $0.id == b.id }).map { gameManager.players[$0].score } ?? 0)
                }) { player in
                    HStack(spacing: 24) {
                        Text(player.name)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(gameManager.players.firstIndex(where: { $0.id == player.id }).map { String(gameManager.players[$0].score) } ?? "0") pts")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    .padding(20)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding(40)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(16)
            
            if gameManager.currentRound < gameManager.totalRounds {
                Button(action: nextRound) {
                    Text("Next Round")
                        .font(.system(size: 36, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(32)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .padding(40)
            }
            
            Spacer()
        }
        .padding(60)
    }
    
    private func nextRound() {
        Task {
            await gameManager.startRound()
        }
    }
}

struct TVGameEndedView: View {
    @ObservedObject var gameManager: MultiplayerGameManager
    
    var body: some View {
        VStack(spacing: 60) {
            Text("Game Over!")
                .font(.system(size: 72, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 24) {
                ForEach(gameManager.players.sorted { a, b in
                    (gameManager.players.firstIndex(where: { $0.id == a.id }).map { gameManager.players[$0].score } ?? 0) >
                    (gameManager.players.firstIndex(where: { $0.id == b.id }).map { gameManager.players[$0].score } ?? 0)
                }) { player in
                    HStack(spacing: 24) {
                        Text(player.name)
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(gameManager.players.firstIndex(where: { $0.id == player.id }).map { String(gameManager.players[$0].score) } ?? "0") pts")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    .padding(32)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                }
            }
            .padding(40)
            
            Spacer()
        }
        .padding(60)
    }
}

#Preview {
    TVContentView()
}
