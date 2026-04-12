import Foundation

public class CardDatabase {
    private var allCards: [Duo] = []
    
    public init() {
        loadCards()
    }
    
    private func loadCards() {
        // Try to load from the FamousPeersCore resource bundle
        let bundleName = "FamousPeersCore_FamousPeersCore"
        guard let bundleURL = Bundle(for: CardDatabase.self).url(forResource: bundleName, withExtension: "bundle"),
              let resourceBundle = Bundle(url: bundleURL),
              let url = resourceBundle.url(forResource: "cards", withExtension: "json") else {
            print("Error: cards.json not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            allCards = try JSONDecoder().decode([Duo].self, from: data)
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
    
    public func getAllCards() -> [Duo] {
        return allCards
    }
}
