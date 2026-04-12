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
        
        let state = GameStateMessage(
            round: game.currentRound,
            gameState: game.gameState.rawValue,
            askerIndex: game.getCurrentAsker().name,
            guesserIndex: game.getCurrentGuesser().name,
            clue: game.getCurrentClue(),
            scores: game.players.map { $0.score }
        )
        
        if let data = try? JSONEncoder().encode(state) {
            gameKitManager.sendMessage(data)
        }
    }
    
    public func submitAnswer(_ answer: String) {
        guard let game = gameLogic else { return }
        
        let isCorrect = game.submitAnswer(answer)
        
        let message = AnswerMessage(
            answer: answer,
            isCorrect: isCorrect,
            playerName: game.getCurrentGuesser().name
        )
        
        if let data = try? JSONEncoder().encode(message) {
            gameKitManager.sendMessage(data)
        }
    }
    
    // MARK: - GameKitManagerDelegate
    
    public func gameKitManager(_ manager: GameKitManager, didReceiveMessage data: Data, from player: GKPlayer) {
        // Try to decode as different message types
        if let stateMessage = try? JSONDecoder().decode(GameStateMessage.self, from: data) {
            handleGameStateUpdate(stateMessage)
        } else if let answerMessage = try? JSONDecoder().decode(AnswerMessage.self, from: data) {
            handleAnswerUpdate(answerMessage)
        }
    }
    
    public func gameKitManager(_ manager: GameKitManager, playerConnected player: GKPlayer) {
        isConnected = true
        remotePlayerName = player.displayName
    }
    
    public func gameKitManager(_ manager: GameKitManager, playerDisconnected player: GKPlayer) {
        isConnected = false
        remotePlayerName = nil
    }
    
    private func handleGameStateUpdate(_ message: GameStateMessage) {
        guard let game = gameLogic else { return }
        
        // Update local game state with remote state
        // This ensures both players stay in sync
        DispatchQueue.main.async {
            // Update scores
            for (index, score) in message.scores.enumerated() {
                if index < game.players.count {
                    game.players[index].score = score
                }
            }
        }
    }
    
    private func handleAnswerUpdate(_ message: AnswerMessage) {
        // Handle remote player's answer
        // This is used to update the UI with the remote player's action
    }
}

// MARK: - Message Types

struct GameStateMessage: Codable {
    let round: Int
    let gameState: String
    let askerIndex: String
    let guesserIndex: String
    let clue: String
    let scores: [Int]
}

struct AnswerMessage: Codable {
    let answer: String
    let isCorrect: Bool
    let playerName: String
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
