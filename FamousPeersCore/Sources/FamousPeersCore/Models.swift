import Foundation

// MARK: - Core Models

public struct Duo: Codable, Identifiable {
    public let id: Int
    public let uuid: String
    public let category: String
    public let duoName: String
    public let members: [[AnyCodable]] // Array of [name, difficulty] pairs
    public let difficulty: Int
    public let hint: String
    public let trivia: String?
    
    // Helper properties for backward compatibility
    public var member1: String { duoName }
    public var member2: String { 
        guard let first = members.first, first.count > 0 else { return "" }
        return first[0].value as? String ?? ""
    }
}

// Helper type to handle mixed types in JSON
public enum AnyCodable: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case null
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode AnyCodable")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let string):
            try container.encode(string)
        case .int(let int):
            try container.encode(int)
        case .double(let double):
            try container.encode(double)
        case .bool(let bool):
            try container.encode(bool)
        case .null:
            try container.encodeNil()
        }
    }
    
    var value: Any {
        switch self {
        case .string(let string): return string
        case .int(let int): return int
        case .double(let double): return double
        case .bool(let bool): return bool
        case .null: return NSNull()
        }
    }
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
