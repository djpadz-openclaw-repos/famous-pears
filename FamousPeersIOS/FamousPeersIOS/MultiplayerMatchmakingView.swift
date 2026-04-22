import SwiftUI
import FamousPeersCore
import GameKit

struct MultiplayerMatchmakingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var gameKitManager = GameKitManager.shared
    @State private var isSearching = false
    @State private var matchFound = false
    @State private var errorMessage: String?
    
    var onMatchFound: (GKMatch) -> Void
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                HStack {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                VStack(spacing: 20) {
                    if isSearching {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                            
                            Text("Searching for opponent...")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Waiting for another player to join")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Button(action: { cancelSearch() }) {
                                Text("Cancel")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.opacity(0.3))
                                    .foregroundColor(.red)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                    } else if let error = errorMessage {
                        VStack(spacing: 15) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.red)
                            
                            Text("Error")
                                .font(.headline)
                            
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                            Button(action: { startSearch() }) {
                                Text("Try Again")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.blue)
                            
                            Text("Ready to Play?")
                                .font(.headline)
                            
                            Text("Find another player and start a game")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                            Button(action: { startSearch() }) {
                                Text("Find Opponent")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            setupGameKitDelegate()
        }
    }
    
    private func setupGameKitDelegate() {
        // The delegate will be set up when we start matchmaking
    }
    
    private func startSearch() {
        isSearching = true
        errorMessage = nil
        
        // Get the presenting view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            gameKitManager.startMatchmaking(minPlayers: 2, maxPlayers: 2, presentingViewController: rootViewController)
        }
    }
    
    private func cancelSearch() {
        isSearching = false
        gameKitManager.disconnect()
    }
}

#Preview {
    MultiplayerMatchmakingView(onMatchFound: { _ in })
}
