import Foundation

// MARK: - Core Models

public struct Duo: Codable, Identifiable {
    public let id: Int
    public let category: String
    public let member1: String
    public let member2: String
    public let difficulty: Int
    public let hint: String
}

public struct Player: Identifiable {
    public let id: UUID
    public var name: String
    public var score: Int = 0
    
    public init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

public struct GameRound {
    public let roundNumber: Int
    public let asker: Player
    public let guesser: Player
    public let duo: Duo
    public var clue: String = ""
    public var answer: String = ""
    public var isCorrect: Bool = false
    public var pointsAwarded: Int = 0
}

public enum GameState {
    case setup
    case playing
    case roundComplete
    case gameOver
}

public enum DifficultyMode: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case mixed = "Mixed"
    
    public var pointRange: ClosedRange<Int> {
        switch self {
        case .easy: return 1...2
        case .medium: return 2...3
        case .hard: return 4...5
        case .mixed: return 1...5
        }
    }
}
