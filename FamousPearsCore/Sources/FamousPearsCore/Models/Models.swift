import Foundation

public struct Duo: Codable, Identifiable {
    public let id: Int
    public let category: String
    public let member1: String
    public let member2: String
    public let difficulty: Int
    public let hint: String
    
    public init(id: Int, category: String, member1: String, member2: String, difficulty: Int, hint: String) {
        self.id = id
        self.category = category
        self.member1 = member1
        self.member2 = member2
        self.difficulty = difficulty
        self.hint = hint
    }
}

public struct Player: Identifiable {
    public let id: UUID
    public let name: String
    public var score: Int = 0
    
    public init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

public struct GameRound {
    public let duoId: Int
    public let asker: Player
    public let guesser: Player
    public let clue: String
    public var answer: String?
    public var isCorrect: Bool?
    public var pointsAwarded: Int = 0
    
    public init(duoId: Int, asker: Player, guesser: Player, clue: String) {
        self.duoId = duoId
        self.asker = asker
        self.guesser = guesser
        self.clue = clue
    }
}

public enum GameState {
    case setup
    case playing
    case roundComplete
    case gameOver
}
