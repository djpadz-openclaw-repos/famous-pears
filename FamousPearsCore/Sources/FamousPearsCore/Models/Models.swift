import Foundation

public struct Duo: Codable, Identifiable {
    public let id: Int
    public let category: String
    public let duoName: String
    public let member1: String
    public let member2: String
    public let difficulty: Int
    public let hint: String
    
    public init(id: Int, category: String, duoName: String, member1: String, member2: String, difficulty: Int, hint: String) {
        self.id = id
        self.category = category
        self.duoName = duoName
        self.member1 = member1
        self.member2 = member2
        self.difficulty = difficulty
        self.hint = hint
    }
    
    public func getRandomMember() -> String {
        Bool.random() ? member1 : member2
    }
    
    public func getOtherMember(_ member: String) -> String {
        member == member1 ? member2 : member1
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
    public let duoName: String
    public let readMember: String
    public let correctAnswer: String
    public var submittedAnswer: String?
    public var isCorrect: Bool?
    public var pointsAwarded: Int = 0
    
    public init(duoId: Int, asker: Player, guesser: Player, duoName: String, readMember: String, correctAnswer: String) {
        self.duoId = duoId
        self.asker = asker
        self.guesser = guesser
        self.duoName = duoName
        self.readMember = readMember
        self.correctAnswer = correctAnswer
    }
}

public enum GameState {
    case setup
    case playing
    case roundComplete
    case gameOver
}

public enum DifficultyMode {
    case easy      // 1-2 point duos
    case medium    // 2-3 point duos
    case hard      // 4-5 point duos
    case mixed     // all difficulties
    
    public var pointRange: ClosedRange<Int> {
        switch self {
        case .easy: return 1...2
        case .medium: return 2...3
        case .hard: return 4...5
        case .mixed: return 1...5
        }
    }
}
