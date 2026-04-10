import Foundation

public protocol GameMessage: Codable {
    var messageType: String { get }
}

public struct RoundStartedMessage: GameMessage {
    public let messageType = "roundStarted"
    public let roundNumber: Int
    public let askerName: String
    public let guesserName: String
    public let clue: String
    public let duo: Duo
    
    public init(roundNumber: Int, askerName: String, guesserName: String, clue: String, duo: Duo) {
        self.roundNumber = roundNumber
        self.askerName = askerName
        self.guesserName = guesserName
        self.clue = clue
        self.duo = duo
    }
}

public struct AnswerSubmittedMessage: GameMessage {
    public let messageType = "answerSubmitted"
    public let guesserName: String
    public let answer: String
    
    public init(guesserName: String, answer: String) {
        self.guesserName = guesserName
        self.answer = answer
    }
}

public struct RoundResultMessage: GameMessage {
    public let messageType = "roundResult"
    public let isCorrect: Bool
    public let pointsAwarded: Int
    public let correctAnswer: String
    
    public init(isCorrect: Bool, pointsAwarded: Int, correctAnswer: String) {
        self.isCorrect = isCorrect
        self.pointsAwarded = pointsAwarded
        self.correctAnswer = correctAnswer
    }
}

public struct GameStateMessage: GameMessage {
    public let messageType = "gameState"
    public let state: String
    public let leaderboard: [String: Int]
    
    public init(state: String, leaderboard: [String: Int]) {
        self.state = state
        self.leaderboard = leaderboard
    }
}

public struct GameEndedMessage: GameMessage {
    public let messageType = "gameEnded"
    public let winner: String
    public let finalScores: [String: Int]
    
    public init(winner: String, finalScores: [String: Int]) {
        self.winner = winner
        self.finalScores = finalScores
    }
}

public class MessageEncoder {
    public static func encode(_ message: GameMessage) -> Data? {
        try? JSONEncoder().encode(message)
    }
    
    public static func decode(_ data: Data) -> GameMessage? {
        // Try decoding each message type
        if let msg = try? JSONDecoder().decode(RoundStartedMessage.self, from: data) {
            return msg
        }
        if let msg = try? JSONDecoder().decode(AnswerSubmittedMessage.self, from: data) {
            return msg
        }
        if let msg = try? JSONDecoder().decode(RoundResultMessage.self, from: data) {
            return msg
        }
        if let msg = try? JSONDecoder().decode(GameStateMessage.self, from: data) {
            return msg
        }
        if let msg = try? JSONDecoder().decode(GameEndedMessage.self, from: data) {
            return msg
        }
        return nil
    }
}
