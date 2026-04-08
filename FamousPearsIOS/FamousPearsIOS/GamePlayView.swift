import SwiftUI
import FamousPearsCore

struct GamePlayView: View {
    @ObservedReferencedObject var gameLogic: GameLogic
    @State private var answerText = ""
    @State private var currentRoundIndex = 0
    @State private var showResult = false
    @State private var resultMessage = ""
    @State private var isCorrect = false
    @State private var showNextButton = false
    
    var onGameEnd: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Famous Pears")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text("Round \(gameLogic.rounds.count + 1)/\(gameLogic.maxRounds)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            
            if let round = gameLogic.currentRound {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Text("\(round.guesser.name), guess the pair!")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text(round.clue)
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                            .popIn()
                    }
                    
                    if !showResult {
                        VStack(spacing: 12) {
                            TextField("Your answer", text: $answerText)
                                .textFieldStyle(.roundedBorder)
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Button(action: submitAnswer) {
                                Text("Submit Answer")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal)
                            .disabled(answerText.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                        .slideIn(from: .bottom)
                    } else {
                        ResultCard(
                            isCorrect: isCorrect,
                            message: resultMessage,
                            pointsAwarded: round.pointsAwarded
                        )
                        .popIn()
                        
                        if showNextButton {
                            Button(action: nextRound) {
                                Text("Next Round")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal)
                            .slideIn(from: .bottom)
                        }
                    }
                }
                .padding()
            }
            
            ScoreboardView(players: gameLogic.players)
                .slideIn(from: .leading)
            
            Spacer()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
    
    private func submitAnswer() {
        let isCorrect = gameLogic.submitAnswer(answerText)
        self.isCorrect = isCorrect
        self.resultMessage = isCorrect ? "Correct! 🎉" : "Incorrect ❌"
        
        withAnimation(AnimationConstants.spring) {
            showResult = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(AnimationConstants.easeInOut) {
                showNextButton = true
            }
        }
    }
    
    private func nextRound() {
        if gameLogic.isGameOver() {
            onGameEnd()
        } else {
            let nextAskerIndex = (currentRoundIndex + 1) % gameLogic.players.count
            _ = gameLogic.startNewRound(askerIndex: nextAskerIndex)
            
            answerText = ""
            showResult = false
            showNextButton = false
            currentRoundIndex += 1
        }
    }
}

struct ResultCard: View {
    let isCorrect: Bool
    let message: String
    let pointsAwarded: Int
    
    var body: some View {
        VStack(spacing: 12) {
            Text(message)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(isCorrect ? .green : .red)
            
            if isCorrect {
                Text("+\(pointsAwarded) points")
                    .font(.headline)
                    .foregroundColor(.green)
                    .scaleEffect(1.2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCorrect ? Color.green : Color.red, lineWidth: 2)
        )
    }
}

struct ScoreboardView: View {
    let players: [Player]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Scores")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(players.sorted { $0.score > $1.score }) { player in
                HStack {
                    Text(player.name)
                        .font(.headline)
                    Spacer()
                    Text("\(player.score) pts")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.white.opacity(0.6))
                .cornerRadius(8)
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color.white.opacity(0.3))
        .cornerRadius(12)
        .padding()
    }
}

#Preview {
    GamePlayView(gameLogic: GameLogic(players: [Player(name: "Alice"), Player(name: "Bob")])) {}
}
