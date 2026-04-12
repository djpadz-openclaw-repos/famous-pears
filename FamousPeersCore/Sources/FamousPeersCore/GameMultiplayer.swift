import Foundation
import GameKit
import Combine

public class GameMultiplayer: NSObject, GameKitManagerDelegate, ObservableObject {
    @Published public var isConnected = false
    @Published public var remotePlayerName: String?
    
    private var gameLogic: GameLogic?
    private var gameKitManager: GameKitManager
    private var cancellables = Set<AnyCancellable>()
    
    public override init() {
        gameKitManager = GameKitManager.shared
        super.init()
        gameKitManager.delegate = self
    }
    
    public func startMultiplayerGame(players: [Player], difficulty: DifficultyMode) {
        let game = GameLogic(players: players, difficulty: difficulty)
        self.gameLogic = game
        
        // Listen to game state changes and sync them
        game.$gameState
            .dropFirst()
            .sink { [weak self] _ in
                self?.syncGameState()
            }
            .store(in: &cancellables)
        
        game.startGame()
    }
    
    public func getGameLogic() -> GameLogic? {
        return gameLogic
    }
    
    // MARK: - Game State Synchronization
    
    private func syncGameState() {
        guard let game = gameLogic else { return }
        
        let leaderboard = Dictionary(uniqueKeysWithValues: game.players.map { ($0.name, $0.score) })
        let state = GameStateMessage(
            state: game.gameState.rawValue,
            leaderboard: leaderboard
        )
        
        if let data = MessageEncoder.encode(state) {
            gameKitManager.sendMessage(data)
        }
    }
    
    public func submitAnswer(_ answer: String) {
        guard let game = gameLogic else { return }
        
        _ = game.submitAnswer(answer)
        
        let message = AnswerSubmittedMessage(
            guesserName: game.getCurrentGuesser().name,
            answer: answer
        )
        
        if let data = MessageEncoder.encode(message) {
            gameKitManager.sendMessage(data)
        }
    }
    
    // MARK: - GameKitManagerDelegate
    
    public func gameKitManager(_ manager: GameKitManager, didReceiveMessage data: Data, from player: GKPlayer) {
        // Decode message using MessageEncoder
        if let message = MessageEncoder.decode(data) {
            if let stateMessage = message as? GameStateMessage {
                handleGameStateUpdate(stateMessage)
            } else if let answerMessage = message as? AnswerSubmittedMessage {
                handleAnswerUpdate(answerMessage)
            }
        }
    }
    
    public func gameKitManager(_ manager: GameKitManager, playerConnected player: GKPlayer) {
        DispatchQueue.main.async {
            self.isConnected = true
            self.remotePlayerName = player.displayName
        }
    }
    
    public func gameKitManager(_ manager: GameKitManager, playerDisconnected player: GKPlayer) {
        DispatchQueue.main.async {
            self.isConnected = false
            self.remotePlayerName = nil
        }
    }
    
    private func handleGameStateUpdate(_ message: GameStateMessage) {
        guard let game = gameLogic else { return }
        
        // Update local game state with remote state
        // This ensures both players stay in sync
        DispatchQueue.main.async {
            // Update scores from leaderboard
            for (playerName, score) in message.leaderboard {
                if let index = game.players.firstIndex(where: { $0.name == playerName }) {
                    game.players[index].score = score
                }
            }
        }
    }
    
    private func handleAnswerUpdate(_ message: AnswerSubmittedMessage) {
        // Handle remote player's answer
        // This is used to update the UI with the remote player's action
    }
}

// MARK: - GameState Extension

extension GameState {
    var rawValue: String {
        switch self {
        case .setup:
            return "setup"
        case .playing:
            return "playing"
        case .roundComplete:
            return "roundComplete"
        case .gameOver:
            return "gameOver"
        }
    }
}
