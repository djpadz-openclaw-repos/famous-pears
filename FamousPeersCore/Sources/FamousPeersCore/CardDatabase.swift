import Foundation
import os.log

public class CardDatabase {
    private var allCards: [Duo] = []
    private var cardUsageTracker: [String: Date] = [:] // UUID -> last used time
    
    public init() {
        loadCards()
    }
    
    private func loadCards() {
        os_log("[CardDatabase] Starting loadCards()", log: OSLog.default, type: .debug)
        
        guard let url = Bundle.module.url(forResource: "cards", withExtension: "json") else {
            os_log("[CardDatabase] ERROR: cards.json not found at root", log: OSLog.default, type: .error)
            return
        }
        
        os_log("[CardDatabase] Found cards.json at: %{public}@", log: OSLog.default, type: .debug, url.absoluteString)
        loadCardsFromURL(url)
    }
    
    private func loadCardsFromURL(_ url: URL) {
        do {
            let data = try Data(contentsOf: url)
            os_log("[CardDatabase] Loaded %d bytes from cards.json", log: OSLog.default, type: .debug, data.count)
            
            allCards = try JSONDecoder().decode([Duo].self, from: data)
            os_log("[CardDatabase] Successfully decoded %d cards", log: OSLog.default, type: .debug, allCards.count)
            
            if allCards.isEmpty {
                os_log("[CardDatabase] WARNING: allCards is empty after decoding", log: OSLog.default, type: .info)
            }
        } catch {
            os_log("[CardDatabase] ERROR loading cards: %{public}@", log: OSLog.default, type: .error, error.localizedDescription)
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
        guard !filtered.isEmpty else {
            os_log("[CardDatabase] WARNING: No cards available for difficulty", log: OSLog.default, type: .info)
            return nil
        }
        
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
        
        // Guard against invalid range (totalWeight must be > 0)
        guard totalWeight > 0 else {
            os_log("[CardDatabase] WARNING: totalWeight is 0, using random selection", log: OSLog.default, type: .info)
            let selectedCard = filtered.randomElement()!
            cardUsageTracker[selectedCard.uuid] = now
            return selectedCard
        }
        
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
