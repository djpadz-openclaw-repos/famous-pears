import SwiftUI
import FamousPeersCore

struct GamePlayView: View {
    @ObservedObject var gameLogic: GameLogic
    @State private var answerText = ""
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var resultMessage = ""
    @State private var showNextButton = false
    
    var onGameEnd: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Famous Peers")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text("Round \(gameLogic.currentRound)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            
            // Current players
            HStack {
                VStack(alignment: .leading) {
                    Text("Asker")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(gameLogic.getCurrentAsker().name)
                        .font(.headline)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Guesser")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(gameLogic.getCurrentGuesser().name)
                        .font(.headline)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding()
            
            Spacer()
            
            // Clue
            VStack(spacing: 12) {
                Text("The clue is:")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(gameLogic.getCurrentClue())
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
            }
            .padding()
            
            Spacer()
            
            // Answer input or result
            if !showResult {
                VStack(spacing: 12) {
                    TextField("Enter your guess", text: $answerText)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    
                    Button(action: submitAnswer) {
                        Text("Submit Answer")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                }
            } else {
                VStack(spacing: 16) {
                    Text(resultMessage)
                        .font(.headline)
                        .foregroundColor(isCorrect ? .green : .red)
                    
                    if isCorrect {
                        Text("Correct! +\(gameLogic.getCurrentDuo()?.difficulty ?? 0) points")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                    
                    if showNextButton {
                        Button(action: nextRound) {
                            Text(gameLogic.gameState == .gameOver ? "Game Over" : "Next Round")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding()
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding()
            }
            
            Spacer()
        }
        .onChange(of: gameLogic.gameState) { newState in
            if newState == .gameOver {
                onGameEnd()
            }
        }
    }
    
    private func submitAnswer() {
        isCorrect = gameLogic.submitAnswer(answerText)
        resultMessage = isCorrect ? "Correct!" : "Incorrect"
        showResult = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showNextButton = true
        }
    }
    
    private func nextRound() {
        if gameLogic.gameState == .gameOver {
            onGameEnd()
        } else {
            answerText = ""
            showResult = false
            showNextButton = false
            gameLogic.nextRound()
        }
    }
}

#Preview {
    let players = [Player(name: "Player 1"), Player(name: "Player 2")]
    let gameLogic = GameLogic(players: players, difficulty: .mixed)
    gameLogic.startGame()
    
    return GamePlayView(gameLogic: gameLogic, onGameEnd: {})
}
