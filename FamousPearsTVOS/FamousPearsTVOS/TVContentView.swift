import SwiftUI
import FamousPearsCore

struct TVContentView: View {
    @State private var gameLogic: GameLogic?
    @State private var players: [Player] = [
        Player(name: "Player 1"),
        Player(name: "Player 2")
    ]
    @State private var gameStarted = false
    
    var body: some View {
        if gameStarted, let game = gameLogic {
            TVGameView(gameLogic: game)
        } else {
            TVSetupView(players: $players, onStart: startGame)
        }
    }
    
    private func startGame() {
        let game = GameLogic(players: players)
        game.startGame()
        gameLogic = game
        gameStarted = true
    }
}

struct TVSetupView: View {
    @Binding var players: [Player]
    var onStart: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("Famous Pears")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Guess the famous duo!")
                    .font(.system(size: 32))
                    .foregroundColor(.gray)
                
                VStack(spacing: 20) {
                    ForEach($players) { $player in
                        TextField("Player name", text: $player.name)
                            .font(.system(size: 28))
                            .textFieldStyle(.roundedBorder)
                            .frame(height: 60)
                            .padding(.horizontal, 40)
                    }
                }
                
                Button(action: onStart) {
                    Text("Start Game")
                        .font(.system(size: 32, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding(40)
        }
    }
}

struct TVGameView: View {
    @ObservedReferencedObject var gameLogic: GameLogic
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("Famous Pears")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                
                if let round = gameLogic.currentRound {
                    VStack(spacing: 30) {
                        Text("\(round.guesser.name), guess the pair!")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(round.clue)
                            .font(.system(size: 72, weight: .bold))
                            .foregroundColor(.yellow)
                            .padding(40)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(16)
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Scores")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.white)
                    
                    ForEach(gameLogic.players) { player in
                        HStack {
                            Text(player.name)
                                .font(.system(size: 28))
                            Spacer()
                            Text("\(player.score) pts")
                                .font(.system(size: 28, weight: .semibold))
                        }
                        .foregroundColor(.white)
                    }
                }
                .padding(30)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding(40)
        }
    }
}

#Preview {
    TVContentView()
}
