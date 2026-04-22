import SwiftUI
import FamousPeersCore

struct GamePlayView: View {
    @ObservedObject var gameLogic: GameLogic
    @State private var answerText = ""
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var resultMessage = ""
    @State private var showNextButton = false
    @State private var computerGuess = ""
    @State private var showComputerGuess = false
    @State private var isProcessingComputerTurn = false
    
    var onGameEnd: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // DEBUG: Log game state
            let _ = print("[GamePlayView] Clue: \(gameLogic.getCurrentClue() ?? "nil")")
            let _ = print("[GamePlayView] Current Duo: \(gameLogic.getCurrentDuo()?.name ?? "nil")")
            let _ = print("[GamePlayView] Computer Guesser: \(gameLogic.getCurrentGuesserIsComputer())")
            let _ = print("[GamePlayView] Show Computer Guess: \(showComputerGuess)")
            let _ = print("[GamePlayView] Computer Guess Value: \(computerGuess)")
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
                if gameLogic.getCurrentGuesserIsComputer() {
                    // Computer is guessing
                    VStack(spacing: 12) {
                        if showComputerGuess {
                            VStack(spacing: 12) {
                                Text("Computer's guess:")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text(computerGuess)
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.orange.opacity(0.2))
                                    .cornerRadius(8)
                                
                                Button(action: submitComputerGuess) {
                                    Text("Submit")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .padding()
                            }
                        } else {
                            HStack {
                                ProgressView()
                                Text("Computer is thinking...")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                        }
                    }
                } else {
                    // Human is guessing
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
        .onAppear {
            handleComputerTurn()
        }
        .onChange(of: gameLogic.gameState) { oldState, newState in
            if newState == .gameOver {
                onGameEnd()
            }
        }
    }
    
    private func handleComputerTurn() {
        if gameLogic.getCurrentGuesserIsComputer() && !showComputerGuess {
            isProcessingComputerTurn = true
            print("[handleComputerTurn] Starting computer turn")
            
            // Simulate thinking time
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                let possibleAnswers = ["Answer 1", "Answer 2", "Answer 3"]
                print("[handleComputerTurn] Possible answers: \(possibleAnswers)")
                computerGuess = gameLogic.getComputerGuess(possibleAnswers: possibleAnswers)
                print("[handleComputerTurn] Computer guess result: \(computerGuess)")
                showComputerGuess = true
                isProcessingComputerTurn = false
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
    
    private func submitComputerGuess() {
        isCorrect = gameLogic.submitAnswer(computerGuess)
        resultMessage = isCorrect ? "Computer guessed correctly!" : "Computer guessed incorrectly"
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
            computerGuess = ""
            showResult = false
            showComputerGuess = false
            showNextButton = false
            gameLogic.nextRound()
            handleComputerTurn()
        }
    }
}

#Preview {
    let players = [Player(name: "Player 1"), Player(name: "Computer")]
    let gameLogic = GameLogic(players: players, difficulty: .mixed)
    gameLogic.startGame()
    
    return GamePlayView(gameLogic: gameLogic, onGameEnd: {})
}
