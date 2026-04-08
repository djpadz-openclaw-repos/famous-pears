import Foundation
import GameKit

public class NetworkGameCoordinator: NSObject, ObservableObject {
    @Published public var isHost = false
    @Published public var connectedPlayers: [String] = []
    @Published public var gameState: NetworkGameState = .idle
    @Published public var lastReceivedMessage: GameMessage?
    
    public var onMessageReceived: ((GameMessage) -> Void)?
    
    private var gameKitManager: GameKitManager?
    private var multipeerManager: MultipeerManager?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    public override init() {
        super.init()
    }
    
    public func setupAsHost(using multipeer: MultipeerManager) {
        self.multipeerManager = multipeer
        self.isHost = true
        
        multipeer.onMessageReceived { [weak self] data, peerId in
            self?.handleReceivedData(data)
        }
    }
    
    public func setupAsClient(using gameKit: GameKitManager) {
        self.gameKitManager = gameKit
        self.isHost = false
        
        gameKit.onMessageReceived { [weak self] data, player in
            self?.handleReceivedData(data)
        }
    }
    
    public func broadcastMessage(_ message: GameMessage) {
        guard let data = try? encoder.encode(message) else { return }
        
        if let multipeer = multipeerManager {
            multipeer.sendMessage(data)
        } else if let gameKit = gameKitManager {
            gameKit.sendMessage(data)
        }
    }
    
    public func broadcastRoundStart(duoId: Int, clue: String, guesserName: String) {
        let message = GameMessage.roundStarted(duoId: duoId, clue: clue, guesserName: guesserName)
        broadcastMessage(message)
    }
    
    public func broadcastAnswerSubmission(_ answer: String, playerId: String) {
        let message = GameMessage.answerSubmitted(answer: answer, playerId: playerId)
        broadcastMessage(message)
    }
    
    public func broadcastRoundResult(isCorrect: Bool, pointsAwarded: Int, correctAnswer: String) {
        let message = GameMessage.roundResult(isCorrect: isCorrect, pointsAwarded: pointsAwarded, correctAnswer: correctAnswer)
        broadcastMessage(message)
    }
    
    public func broadcastGameEnd(leaderboard: [(name: String, score: Int)]) {
        let message = GameMessage.gameEnded(leaderboard: leaderboard)
        broadcastMessage(message)
    }
    
    private func handleReceivedData(_ data: Data) {
        guard let message = try? decoder.decode(GameMessage.self, from: data) else { return }
        
        DispatchQueue.main.async {
            self.lastReceivedMessage = message
            self.onMessageReceived?(message)
        }
    }
}

public enum NetworkGameState {
    case idle
    case connecting
    case connected
    case playing
    case ended
}
