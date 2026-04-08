import Foundation

public struct Duo: Codable, Identifiable {
    public let id: Int
    public let category: String
    public let duoName: String
    public let member1: String
    public let member1Points: Int
    public let member2: String
    public let member2Points: Int
    public let hint: String
    
    public init(id: Int, category: String, duoName: String, member1: String, member1Points: Int, member2: String, member2Points: Int, hint: String) {
        self.id = id
        self.category = category
        self.duoName = duoName
        self.member1 = member1
        self.member1Points = member1Points
        self.member2 = member2
        self.member2Points = member2Points
        self.hint = hint
    }
    
    public func getRandomMember() -> String {
        Bool.random() ? member1 : member2
    }
    
    public func getOtherMember(_ member: String) -> String {
        member == member1 ? member2 : member1
    }
    
    public func getPointsForMember(_ member: String) -> Int {
        member == member1 ? member1Points : member2Points
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
    public let pointsIfCorrect: Int
    public var submittedAnswer: String?
    public var isCorrect: Bool?
    public var pointsAwarded: Int = 0
    
    public init(duoId: Int, asker: Player, guesser: Player, duoName: String, readMember: String, correctAnswer: String, pointsIfCorrect: Int) {
        self.duoId = duoId
        self.asker = asker
        self.guesser = guesser
        self.duoName = duoName
        self.readMember = readMember
        self.correctAnswer = correctAnswer
        self.pointsIfCorrect = pointsIfCorrect
    }
}

public enum GameState {
    case setup
    case playing
    case roundComplete
    case gameOver
}

public enum DifficultyMode {
    case easy      // 1-2 point answers
    case medium    // 2-3 point answers
    case hard      // 3-5 point answers
    case mixed     // all point values
    
    public func shouldIncludePoints(_ points: Int) -> Bool {
        switch self {
        case .easy: return points <= 2
        case .medium: return points >= 2 && points <= 3
        case .hard: return points >= 3
        case .mixed: return true
        }
    }
}
