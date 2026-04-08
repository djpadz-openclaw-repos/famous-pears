import Foundation

public enum GameMessage: Codable {
    case playerJoined(playerName: String, playerId: String)
    case roundStarted(duoId: Int, clue: String, guesserName: String)
    case answerSubmitted(answer: String, playerId: String)
    case roundResult(isCorrect: Bool, pointsAwarded: Int, correctAnswer: String)
    case gameEnded(leaderboard: [(name: String, score: Int)])
    case difficultySelected(difficulty: String)
    
    enum CodingKeys: String, CodingKey {
        case type, playerName, playerId, duoId, clue, guesserName, answer, isCorrect, pointsAwarded, correctAnswer, leaderboard, difficulty
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .playerJoined(let name, let id):
            try container.encode("playerJoined", forKey: .type)
            try container.encode(name, forKey: .playerName)
            try container.encode(id, forKey: .playerId)
        case .roundStarted(let duoId, let clue, let guesserName):
            try container.encode("roundStarted", forKey: .type)
            try container.encode(duoId, forKey: .duoId)
            try container.encode(clue, forKey: .clue)
            try container.encode(guesserName, forKey: .guesserName)
        case .answerSubmitted(let answer, let playerId):
            try container.encode("answerSubmitted", forKey: .type)
            try container.encode(answer, forKey: .answer)
            try container.encode(playerId, forKey: .playerId)
        case .roundResult(let isCorrect, let points, let answer):
            try container.encode("roundResult", forKey: .type)
            try container.encode(isCorrect, forKey: .isCorrect)
            try container.encode(points, forKey: .pointsAwarded)
            try container.encode(answer, forKey: .correctAnswer)
        case .gameEnded(let leaderboard):
            try container.encode("gameEnded", forKey: .type)
            try container.encode(leaderboard.map { ["name": $0.name, "score": $0.score] }, forKey: .leaderboard)
        case .difficultySelected(let difficulty):
            try container.encode("difficultySelected", forKey: .type)
            try container.encode(difficulty, forKey: .difficulty)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "playerJoined":
            let name = try container.decode(String.self, forKey: .playerName)
            let id = try container.decode(String.self, forKey: .playerId)
            self = .playerJoined(playerName: name, playerId: id)
        case "roundStarted":
            let duoId = try container.decode(Int.self, forKey: .duoId)
            let clue = try container.decode(String.self, forKey: .clue)
            let guesserName = try container.decode(String.self, forKey: .guesserName)
            self = .roundStarted(duoId: duoId, clue: clue, guesserName: guesserName)
        case "answerSubmitted":
            let answer = try container.decode(String.self, forKey: .answer)
            let playerId = try container.decode(String.self, forKey: .playerId)
            self = .answerSubmitted(answer: answer, playerId: playerId)
        case "roundResult":
            let isCorrect = try container.decode(Bool.self, forKey: .isCorrect)
            let points = try container.decode(Int.self, forKey: .pointsAwarded)
            let answer = try container.decode(String.self, forKey: .correctAnswer)
            self = .roundResult(isCorrect: isCorrect, pointsAwarded: points, correctAnswer: answer)
        case "gameEnded":
            let leaderboard = try container.decode([[String: Int]].self, forKey: .leaderboard)
            let parsed = leaderboard.compactMap { dict -> (String, Int)? in
                guard let name = dict["name"], let score = dict["score"] else { return nil }
                return (String(name), score)
            }
            self = .gameEnded(leaderboard: parsed)
        case "difficultySelected":
            let difficulty = try container.decode(String.self, forKey: .difficulty)
            self = .difficultySelected(difficulty: difficulty)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown message type")
        }
    }
}
