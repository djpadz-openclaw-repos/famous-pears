import SwiftUI
import FamousPearsCore

struct TVGameView: View {
    @ObservedReferencedObject var gameLogic: GameLogic
    @StateObject private var networkCoordinator = NetworkGameCoordinator()
    @EnvironmentObject var multipeerManager: MultipeerManager
    @State private var currentRoundIndex = 0
    @State private var showResult = false
    @State private var resultMessage = ""
    @State private var lastSubmittedAnswer = ""
    @State private var isCorrect = false
    @State private var waitingForAnswer = false
    @State private var answerTimeout: Timer?
    
    var onGameEnd: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            HStack {
                Text("Famous Pears")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.cyan)
                Spacer()
                Text("Round \(gameLogic.rounds.count + 1)/\(gameLogic.maxRounds)")
                    .font(.system(size: 36))
                    .foregroundColor(.gray)
                Image(systemName: "network")
                    .font(.system(size: 28))
                    .foregroundColor(.green)
            }
            .padding(40)
            
            if let round = gameLogic.currentRound {
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        Text("\(round.guesser.name), guess the pair!")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundColor(.white)
                        
                        if waitingForAnswer {
                            Text("Waiting for answer...")
                                .font(.system(size: 32))
                                .foregroundColor(.yellow)
                                .pulse()
                        }
                    }
                    
                    Text(round.clue)
                        .font(.system(size: 96, weight: .bold))
                        .foregroundColor(.yellow)
                        .padding(60)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(24)
                        .popIn()
                    
                    if showResult {
                        TVResultCard(
                            isCorrect: isCorrect,
                            message: resultMessage,
                            pointsAwarded: round.pointsAwarded,
                            submittedAnswer: lastSubmittedAnswer
                        )
                        .popIn()
                    }
                }
                .padding(40)
            }
            
            TVScoreboardView(players: gameLogic.players)
                .padding(40)
            
            Spacer()
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            setupNetworkHandling()
            startNextRound()
        }
    }
    
    private func setupNetworkHandling() {
        networkCoordinator.setupAsHost(using: multipeerManager)
        
        networkCoordinator.onMessageReceived = { [weak self] message in
            self?.handleNetworkMessage(message)
        }
    }
    
    private func handleNetworkMessage(_ message: GameMessage) {
        switch message {
        case .answerSubmitted(let answer, let playerId):
            handleAnswerSubmission(answer)
            
        default:
            break
        }
    }
    
    private func startNextRound() {
        if gameLogic.isGameOver() {
            broadcastGameEnd()
            onGameEnd()
            return
        }
        
        let nextAskerIndex = currentRoundIndex % gameLogic.players.count
        guard let round = gameLogic.startNewRound(askerIndex: nextAskerIndex) else {
            onGameEnd()
            return
        }
        
        // Broadcast round start to all connected players
        networkCoordinator.broadcastRoundStart(
            duoId: round.duoId,
            clue: round.clue,
            guesserName: round.guesser.name
        )
        
        showResult = false
        waitingForAnswer = true
        lastSubmittedAnswer = ""
        
        // Set 30-second timeout for answer
        answerTimeout?.invalidate()
        answerTimeout = Timer.scheduledTimer(withTimeInterval: 30, repeats: false) { _ in
            if waitingForAnswer {
                handleAnswerTimeout()
            }
        }
    }
    
    private func handleAnswerSubmission(_ answer: String) {
        guard waitingForAnswer, let round = gameLogic.currentRound else { return }
        
        answerTimeout?.invalidate()
        waitingForAnswer = false
        lastSubmittedAnswer = answer
        
        // Check answer
        isCorrect = gameLogic.submitAnswer(answer)
        resultMessage = isCorrect ? "Correct! 🎉" : "Incorrect ❌"
        
        // Broadcast result to all players
        networkCoordinator.broadcastRoundResult(
            isCorrect: isCorrect,
            pointsAwarded: round.pointsAwarded,
            correctAnswer: round.clue
        )
        
        withAnimation(AnimationConstants.spring) {
            showResult = true
        }
        
        // Auto-advance to next round after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            currentRoundIndex += 1
            startNextRound()
        }
    }
    
    private func handleAnswerTimeout() {
        waitingForAnswer = false
        isCorrect = false
        resultMessage = "Time's up! ⏱️"
        lastSubmittedAnswer = "(No answer)"
        
        withAnimation(AnimationConstants.spring) {
            showResult = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            currentRoundIndex += 1
            startNextRound()
        }
    }
    
    private func broadcastGameEnd() {
        let leaderboard = gameLogic.getLeaderboard().map { ($0.name, $0.score) }
        networkCoordinator.broadcastGameEnd(leaderboard: leaderboard)
    }
}

struct TVResultCard: View {
    let isCorrect: Bool
    let message: String
    let pointsAwarded: Int
    let submittedAnswer: String
    
    var body: some View {
        VStack(spacing: 24) {
            Text(message)
                .font(.system(size: 56, weight: .bold))
                .foregroundColor(isCorrect ? .green : .red)
            
            Text("Answer: \(submittedAnswer)")
                .font(.system(size: 32))
                .foregroundColor(.white)
            
            if isCorrect {
                Text("+\(pointsAwarded) points")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.green)
                    .scaleEffect(1.3)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isCorrect ? Color.green : Color.red, lineWidth: 3)
        )
    }
}

struct TVScoreboardView: View {
    let players: [Player]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Scores")
                .font(.system(size: 40, weight: .semibold))
                .foregroundColor(.white)
            
            ForEach(players.sorted { $0.score > $1.score }) { player in
                HStack(spacing: 24) {
                    Text(player.name)
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(player.score) pts")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.cyan)
                }
                .padding(24)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(40)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }
}

#Preview {
    TVGameView(gameLogic: GameLogic(players: [Player(name: "Alice"), Player(name: "Bob")])) {}
        .environmentObject(MultipeerManager.shared)
}
