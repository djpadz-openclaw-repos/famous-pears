import SwiftUI
import FamousPeersCore

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
    @State private var soundManager = SoundManager.shared
    
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
                        Text("\(round.guesser.name), guess the other member!")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundColor(.white)
                        
                        if waitingForAnswer {
                            Text("Waiting for answer...")
                                .font(.system(size: 32))
                                .foregroundColor(.yellow)
                                .pulse()
                        }
                    }
                    
                    VStack(spacing: 24) {
                        Text(round.duoName)
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(.cyan)
                        
                        Text("Given:")
                            .font(.system(size: 32))
                            .foregroundColor(.gray)
                        
                        Text(round.readMember)
                            .font(.system(size: 72, weight: .semibold))
                            .foregroundColor(.green)
                            .padding(40)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(20)
                            .popIn()
                        
                        HStack(spacing: 16) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.yellow)
                            Text("Worth \(round.pointsIfCorrect) points")
                                .font(.system(size: 40, weight: .semibold))
                                .foregroundColor(.yellow)
                        }
                        .padding(24)
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(16)
                    }
                    
                    if showResult {
                        TVResultCard(
                            isCorrect: isCorrect,
                            message: resultMessage,
                            pointsAwarded: round.pointsAwarded,
                            submittedAnswer: lastSubmittedAnswer,
                            correctAnswer: round.correctAnswer
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
        case .answerSubmitted(let answer, _):
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
        
        networkCoordinator.broadcastRoundStart(
            duoId: round.duoId,
            clue: round.readMember,
            guesserName: round.guesser.name
        )
        
        showResult = false
        waitingForAnswer = true
        lastSubmittedAnswer = ""
        
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
        
        isCorrect = gameLogic.submitAnswer(answer)
        resultMessage = isCorrect ? "Correct! 🎉" : "Incorrect ❌"
        
        if isCorrect {
            soundManager.playCorrectSound()
        } else {
            soundManager.playIncorrectSound()
        }
        
        networkCoordinator.broadcastRoundResult(
            isCorrect: isCorrect,
            pointsAwarded: round.pointsAwarded,
            correctAnswer: round.correctAnswer
        )
        
        withAnimation(AnimationConstants.spring) {
            showResult = true
        }
        
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
        
        soundManager.playIncorrectSound()
        
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
    let correctAnswer: String
    
    var body: some View {
        VStack(spacing: 24) {
            Text(message)
                .font(.system(size: 56, weight: .bold))
                .foregroundColor(isCorrect ? .green : .red)
            
            Text("Guessed: \(submittedAnswer)")
                .font(.system(size: 32))
                .foregroundColor(.white)
            
            Text("Correct: \(correctAnswer)")
                .font(.system(size: 32))
                .foregroundColor(.cyan)
            
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
