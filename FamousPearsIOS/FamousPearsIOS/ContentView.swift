import SwiftUI
import FamousPearsCore

struct ContentView: View {
    @State private var gameLogic: GameLogic?
    @State private var players: [Player] = [
        Player(name: "Player 1"),
        Player(name: "Player 2")
    ]
    @State private var gameStarted = false
    
    var body: some View {
        NavigationStack {
            if gameStarted, let game = gameLogic {
                GameView(gameLogic: game)
            } else {
                SetupView(players: $players, onStart: startGame)
            }
        }
    }
    
    private func startGame() {
        let game = GameLogic(players: players)
        game.startGame()
        gameLogic = game
        gameStarted = true
    }
}

struct SetupView: View {
    @Binding var players: [Player]
    var onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Famous Pears")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Guess the famous duo!")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            VStack(spacing: 12) {
                ForEach($players) { $player in
                    TextField("Player name", text: $player.name)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                }
            }
            
            Button(action: onStart) {
                Text("Start Game")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}

struct GameView: View {
    @ObservedReferencedObject var gameLogic: GameLogic
    @State private var answerText = ""
    @State private var showResult = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Famous Pears")
                .font(.title)
                .fontWeight(.bold)
            
            if let round = gameLogic.currentRound {
                VStack(spacing: 16) {
                    Text("\(round.guesser.name), guess the pair!")
                        .font(.headline)
                    
                    Text(round.clue)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    TextField("Your answer", text: $answerText)
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
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Scores")
                    .font(.headline)
                
                ForEach(gameLogic.players) { player in
                    HStack {
                        Text(player.name)
                        Spacer()
                        Text("\(player.score) pts")
                            .fontWeight(.semibold)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            Spacer()
        }
        .padding()
    }
    
    private func submitAnswer() {
        let isCorrect = gameLogic.submitAnswer(answerText)
        showResult = true
        answerText = ""
    }
}

#Preview {
    ContentView()
}
