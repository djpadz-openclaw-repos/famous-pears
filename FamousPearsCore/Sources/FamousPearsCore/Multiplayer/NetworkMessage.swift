import Foundation

public enum NetworkMessage: Codable {
    case playerJoined(PlayerInfo)
    case playerLeft(String)
    case gameStateUpdate(GameStateMessage)
    case playerAnswer(AnswerMessage)
    case scoreUpdate(ScoreMessage)
    case gameStarted(GameStartMessage)
    case gameEnded(GameEndMessage)
    case roundStarted(RoundStartMessage)
    case roundEnded(RoundEndMessage)
    case error(String)
    
    enum CodingKeys: String, CodingKey {
        case type, payload
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "playerJoined":
            let payload = try container.decode(PlayerInfo.self, forKey: .payload)
            self = .playerJoined(payload)
        case "playerLeft":
            let payload = try container.decode(String.self, forKey: .payload)
            self = .playerLeft(payload)
        case "gameStateUpdate":
            let payload = try container.decode(GameStateMessage.self, forKey: .payload)
            self = .gameStateUpdate(payload)
        case "playerAnswer":
            let payload = try container.decode(AnswerMessage.self, forKey: .payload)
            self = .playerAnswer(payload)
        case "scoreUpdate":
            let payload = try container.decode(ScoreMessage.self, forKey: .payload)
            self = .scoreUpdate(payload)
        case "gameStarted":
            let payload = try container.decode(GameStartMessage.self, forKey: .payload)
            self = .gameStarted(payload)
        case "gameEnded":
            let payload = try container.decode(GameEndMessage.self, forKey: .payload)
            self = .gameEnded(payload)
        case "roundStarted":
            let payload = try container.decode(RoundStartMessage.self, forKey: .payload)
            self = .roundStarted(payload)
        case "roundEnded":
            let payload = try container.decode(RoundEndMessage.self, forKey: .payload)
            self = .roundEnded(payload)
        case "error":
            let payload = try container.decode(String.self, forKey: .payload)
            self = .error(payload)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown message type: \(type)")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .playerJoined(let payload):
            try container.encode("playerJoined", forKey: .type)
            try container.encode(payload, forKey: .payload)
        case .playerLeft(let payload):
            try container.encode("playerLeft", forKey: .type)
            try container.encode(payload, forKey: .payload)
        case .gameStateUpdate(let payload):
            try container.encode("gameStateUpdate", forKey: .type)
            try container.encode(payload, forKey: .payload)
        case .playerAnswer(let payload):
            try container.encode("playerAnswer", forKey: .type)
            try container.encode(payload, forKey: .payload)
        case .scoreUpdate(let payload):
            try container.encode("scoreUpdate", forKey: .type)
            try container.encode(payload, forKey: .payload)
        case .gameStarted(let payload):
            try container.encode("gameStarted", forKey: .type)
            try container.encode(payload, forKey: .payload)
        case .gameEnded(let payload):
            try container.encode("gameEnded", forKey: .type)
            try container.encode(payload, forKey: .payload)
        case .roundStarted(let payload):
            try container.encode("roundStarted", forKey: .type)
            try container.encode(payload, forKey: .payload)
        case .roundEnded(let payload):
            try container.encode("roundEnded", forKey: .type)
            try container.encode(payload, forKey: .payload)
        case .error(let payload):
            try container.encode("error", forKey: .type)
            try container.encode(payload, forKey: .payload)
        }
    }
}

public struct PlayerInfo: Codable {
    public let id: String
    public let name: String
    public let joinedAt: Date
    
    public init(id: String, name: String, joinedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.joinedAt = joinedAt
    }
}

public struct GameStateMessage: Codable {
    public let currentRound: Int
    public let totalRounds: Int
    public let currentClue: String
    public let timeRemaining: Int
    public let players: [PlayerInfo]
    
    public init(currentRound: Int, totalRounds: Int, currentClue: String, timeRemaining: Int, players: [PlayerInfo]) {
        self.currentRound = currentRound
        self.totalRounds = totalRounds
        self.currentClue = currentClue
        self.timeRemaining = timeRemaining
        self.players = players
    }
}

public struct AnswerMessage: Codable {
    public let playerId: String
    public let playerName: String
    public let answer: String
    public let roundNumber: Int
    public let timestamp: Date
    
    public init(playerId: String, playerName: String, answer: String, roundNumber: Int, timestamp: Date = Date()) {
        self.playerId = playerId
        self.playerName = playerName
        self.answer = answer
        self.roundNumber = roundNumber
        self.timestamp = timestamp
    }
}

public struct ScoreMessage: Codable {
    public let playerId: String
    public let playerName: String
    public let score: Int
    public let roundsWon: Int
    
    public init(playerId: String, playerName: String, score: Int, roundsWon: Int) {
        self.playerId = playerId
        self.playerName = playerName
        self.score = score
        self.roundsWon = roundsWon
    }
}

public struct GameStartMessage: Codable {
    public let totalRounds: Int
    public let players: [PlayerInfo]
    public let startedAt: Date
    
    public init(totalRounds: Int, players: [PlayerInfo], startedAt: Date = Date()) {
        self.totalRounds = totalRounds
        self.players = players
        self.startedAt = startedAt
    }
}

public struct GameEndMessage: Codable {
    public let winner: PlayerInfo
    public let finalScores: [String: Int]
    public let endedAt: Date
    
    public init(winner: PlayerInfo, finalScores: [String: Int], endedAt: Date = Date()) {
        self.winner = winner
        self.finalScores = finalScores
        self.endedAt = endedAt
    }
}

public struct RoundStartMessage: Codable {
    public let roundNumber: Int
    public let clue: String
    public let difficulty: Int
    public let timeLimit: Int
    
    public init(roundNumber: Int, clue: String, difficulty: Int, timeLimit: Int = 30) {
        self.roundNumber = roundNumber
        self.clue = clue
        self.difficulty = difficulty
        self.timeLimit = timeLimit
    }
}

public struct RoundEndMessage: Codable {
    public let roundNumber: Int
    public let correctAnswer: String
    public let correctPlayers: [String]
    public let pointsAwarded: [String: Int]
    
    public init(roundNumber: Int, correctAnswer: String, correctPlayers: [String], pointsAwarded: [String: Int]) {
        self.roundNumber = roundNumber
        self.correctAnswer = correctAnswer
        self.correctPlayers = correctPlayers
        self.pointsAwarded = pointsAwarded
    }
}
