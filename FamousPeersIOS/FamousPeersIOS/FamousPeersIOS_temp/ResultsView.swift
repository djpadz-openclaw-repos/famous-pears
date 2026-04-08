import SwiftUI
import FamousPeersCore

struct ResultsView: View {
    let leaderboard: [Player]
    var onPlayAgain: () -> Void
    var onExit: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 12) {
                Text("Game Over!")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.blue)
                
                Text("Final Scores")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            .popIn()
            
            VStack(spacing: 16) {
                ForEach(Array(leaderboard.enumerated()), id: \.element.id) { index, player in
                    LeaderboardRow(
                        rank: index + 1,
                        player: player,
                        isWinner: index == 0
                    )
                    .slideIn(from: .leading)
                    .delay(Double(index) * 0.1)
                }
            }
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(12)
            
            VStack(spacing: 12) {
                Button(action: onPlayAgain) {
                    Text("Play Again")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: onExit) {
                    Text("Exit")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .slideIn(from: .bottom)
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

struct LeaderboardRow: View {
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
        HStack(spacing: 16) {
            Text(medalEmoji)
                .font(.system(size: 28))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if isWinner {
                    Text("Winner!")
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
            
            Text("\(player.score) pts")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(isWinner ? .green : .blue)
        }
        .padding()
        .background(isWinner ? Color.green.opacity(0.1) : Color.gray.opacity(0.05))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isWinner ? Color.green : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    ResultsView(
        leaderboard: [
            Player(name: "Alice"),
            Player(name: "Bob"),
            Player(name: "Charlie")
        ].map { player in
            var p = player
            p.score = Int.random(in: 5...20)
            return p
        },
        onPlayAgain: {},
        onExit: {}
    )
}
