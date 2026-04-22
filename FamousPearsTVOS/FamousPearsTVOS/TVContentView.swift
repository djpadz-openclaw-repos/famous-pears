import SwiftUI
import FamousPearsCore

struct TVContentView: View {
    @State private var gameManager: MultiplayerGameManager?
    @State private var hostName = "Apple TV"
    
    var body: some View {
        ZStack {
            if let manager = gameManager {
                TVGameView(gameManager: manager)
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

#Preview {
    TVContentView()
}
