import Foundation

public class GameLogic {
    public var players: [Player]
    public var currentRound: GameRound?
    public var state: GameState = .setup
    public var rounds: [GameRound] = []
    
    private var cardDatabase = CardDatabase.shared
    private var usedCardIds: Set<Int> = []
    
    public init(players: [Player]) {
        self.players = players
    }
    
    public func startGame() {
        state = .playing
        usedCardIds.removeAll()
        rounds.removeAll()
    }
    
    public func startNewRound(askerIndex: Int) -> GameRound? {
        guard askerIndex < players.count else { return nil }
        
        let asker = players[askerIndex]
        let guesserIndex = (askerIndex + 1) % players.count
        let guesser = players[guesserIndex]
        
        guard let duo = getUnusedCard() else {
            endGame()
            return nil
        }
        
        usedCardIds.insert(duo.id)
        let round = GameRound(duoId: duo.id, asker: asker, guesser: guesser, clue: duo.member1)
        currentRound = round
        state = .playing
        
        return round
    }
    
    public func submitAnswer(_ answer: String) -> Bool {
        guard let round = currentRound,
              let duo = cardDatabase.getCard(id: round.duoId) else {
            return false
        }
        
        let isCorrect = Validator.checkAnswer(answer, against: duo.member2)
        currentRound?.answer = answer
        currentRound?.isCorrect = isCorrect
        
        if isCorrect {
            let points = duo.difficulty
            currentRound?.pointsAwarded = points
            
            // Award points to guesser
            if let guesserIndex = players.firstIndex(where: { $0.id == round.guesser.id }) {
                players[guesserIndex].score += points
            }
        }
        
        state = .roundComplete
        return isCorrect
    }
    
    public func endGame() {
        state = .gameOver
    }
    
    public func getLeaderboard() -> [Player] {
        players.sorted { $0.score > $1.score }
    }
    
    private func getUnusedCard() -> Duo? {
        let allCards = cardDatabase.getAllCards()
        return allCards.first { !usedCardIds.contains($0.id) }
    }
}
