import Foundation

public class CardDatabase {
    public static let shared = CardDatabase()
    
    private var duos: [Duo] = []
    
    private init() {
        loadCards()
    }
    
    private func loadCards() {
        guard let url = Bundle.module.url(forResource: "cards", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Duo].self, from: data) else {
            return
        }
        duos = decoded
    }
    
    public func getAllCards() -> [Duo] {
        duos
    }
    
    public func getCardsByDifficulty(_ difficulty: Int) -> [Duo] {
        duos.filter { $0.difficulty == difficulty }
    }
    
    public func getRandomCard() -> Duo? {
        duos.randomElement()
    }
    
    public func getCard(id: Int) -> Duo? {
        duos.first { $0.id == id }
    }
}
