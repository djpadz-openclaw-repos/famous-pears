import Foundation

public enum GameDifficulty: Int, CaseIterable {
    case easy = 1
    case medium = 2
    case hard = 3
    case veryHard = 4
    case expert = 5
    
    public var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .veryHard: return "Very Hard"
        case .expert: return "Expert"
        }
    }
    
    public var description: String {
        switch self {
        case .easy: return "1 point per correct answer"
        case .medium: return "2 points per correct answer"
        case .hard: return "3 points per correct answer"
        case .veryHard: return "4 points per correct answer"
        case .expert: return "5 points per correct answer"
        }
    }
    
    public var timeLimit: Int {
        switch self {
        case .easy: return 45
        case .medium: return 40
        case .hard: return 35
        case .veryHard: return 30
        case .expert: return 25
        }
    }
}

public enum GameMode: String, CaseIterable {
    case mixed = "Mixed"
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"
    
    public var displayName: String {
        self.rawValue
    }
    
    public var description: String {
        switch self {
        case .mixed: return "Random difficulty from all cards"
        case .easy: return "Only easy cards (1 point each)"
        case .medium: return "Only medium cards (2 points each)"
        case .hard: return "Only hard cards (3 points each)"
        case .expert: return "Only expert cards (5 points each)"
        }
    }
    
    public func getDifficulties() -> [Int] {
        switch self {
        case .mixed: return [1, 2, 3, 4, 5]
        case .easy: return [1]
        case .medium: return [2]
        case .hard: return [3]
        case .expert: return [5]
        }
    }
}

public class GameModeManager {
    private let cardDatabase: CardDatabase
    
    public init(cardDatabase: CardDatabase = CardDatabase.shared) {
        self.cardDatabase = cardDatabase
    }
    
    public func getRandomDuo(for mode: GameMode) -> Duo? {
        let difficulties = mode.getDifficulties()
        let allCards = cardDatabase.getAllCards()
        let filteredCards = allCards.filter { difficulties.contains($0.difficulty) }
        return filteredCards.randomElement()
    }
    
    public func getRandomDuos(count: Int, for mode: GameMode) -> [Duo] {
        let difficulties = mode.getDifficulties()
        let allCards = cardDatabase.getAllCards()
        let filteredCards = allCards.filter { difficulties.contains($0.difficulty) }
        
        var selected: [Duo] = []
        var remaining = Set(filteredCards)
        
        for _ in 0..<count {
            guard let duo = remaining.randomElement() else { break }
            selected.append(duo)
            remaining.remove(duo)
        }
        
        return selected
    }
    
    public func getCardsByDifficulty(_ difficulty: GameDifficulty) -> [Duo] {
        cardDatabase.getCardsByDifficulty(difficulty.rawValue)
    }
    
    public func getStatistics(for mode: GameMode) -> GameModeStatistics {
        let difficulties = mode.getDifficulties()
        let allCards = cardDatabase.getAllCards()
        let filteredCards = allCards.filter { difficulties.contains($0.difficulty) }
        
        var categoryCount: [String: Int] = [:]
        for card in filteredCards {
            categoryCount[card.category, default: 0] += 1
        }
        
        return GameModeStatistics(
            totalCards: filteredCards.count,
            cardsByCategory: categoryCount,
            difficulties: difficulties
        )
    }
}

public struct GameModeStatistics {
    public let totalCards: Int
    public let cardsByCategory: [String: Int]
    public let difficulties: [Int]
    
    public var categories: [String] {
        Array(cardsByCategory.keys).sorted()
    }
}
