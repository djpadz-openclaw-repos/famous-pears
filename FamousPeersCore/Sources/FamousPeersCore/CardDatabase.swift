import Foundation

public class CardDatabase {
    private var allCards: [Duo] = []
    private var cardUsageTracker: [String: Date] = [:] // UUID -> last used time
    
    public init() {
        loadCards()
    }
    
    private func loadCards() {
        guard let url = Bundle.module.url(forResource: "cards", withExtension: "json", subdirectory: "Resources") else {
            print("Error: cards.json not found in Resources subdirectory")
            // Try alternative path
            guard let altUrl = Bundle.module.url(forResource: "cards", withExtension: "json") else {
                print("Error: cards.json not found at root")
                return
            }
            loadCardsFromURL(altUrl)
            return
        }
        loadCardsFromURL(url)
    }
    
    private func loadCardsFromURL(_ url: URL) {
        do {
            let data = try Data(contentsOf: url)
            allCards = try JSONDecoder().decode([Duo].self, from: data)
            print("Successfully loaded \(allCards.count) cards")
        } catch {
            print("Error loading cards: \(error)")
        }
    }
    
    public func getCards(for difficulty: DifficultyMode) -> [Duo] {
        let range = difficulty.pointRange
        return allCards.filter { range.contains($0.difficulty) }
    }
    
    public func getRandomCard(for difficulty: DifficultyMode) -> Duo? {
        let filtered = getCards(for: difficulty)
        return filtered.randomElement()
    }
    
    public func getWeightedRandomCard(for difficulty: DifficultyMode, excluding excludedIds: Set<Int> = []) -> Duo? {
        var filtered = getCards(for: difficulty)
        if !excludedIds.isEmpty {
            filtered = filtered.filter { !excludedIds.contains($0.id) }
        }
        guard !filtered.isEmpty else { return nil }
        
        // Calculate weights based on how long ago each card was used
        let now = Date()
        let weights = filtered.map { card -> Double in
            let lastUsed = cardUsageTracker[card.uuid] ?? Date.distantPast
            let timeSinceUsed = now.timeIntervalSince(lastUsed)
            // Weight increases with time since last use (exponential to prefer older cards more)
            return exp(timeSinceUsed / 3600) // Normalize by hours
        }
        
        // Weighted random selection
        let totalWeight = weights.reduce(0, +)
        var randomValue = Double.random(in: 0..<totalWeight)
        
        for (index, weight) in weights.enumerated() {
            randomValue -= weight
            if randomValue <= 0 {
                let selectedCard = filtered[index]
                cardUsageTracker[selectedCard.uuid] = now
                return selectedCard
            }
        }
        
        // Fallback (shouldn't reach here)
        let selectedCard = filtered.last!
        cardUsageTracker[selectedCard.uuid] = now
        return selectedCard
    }
    
    public func getAllCards() -> [Duo] {
        return allCards
    }
    
    public func resetUsageTracker() {
        cardUsageTracker.removeAll()
    }
}
