import Foundation

public class GameLogic {
    public var players: [Player]
    public var currentRound: Int = 0
    public var gameState: GameState = .setup
    public var difficulty: DifficultyMode = .mixed
    
    private let cardDatabase = CardDatabase()
    private var usedCards: Set<Int> = []
    private var currentDuo: Duo?
    private var currentAskerIndex: Int = 0
    private var currentGuesserIndex: Int = 1
    
    public init(players: [Player], difficulty: DifficultyMode = .mixed) {
        self.players = players
        self.difficulty = difficulty
    }
    
    public func startGame() {
        gameState = .playing
        currentRound = 1
        startNewRound()
    }
    
    public func startNewRound() {
        guard players.count >= 2 else { return }
        
        // Get next card
        let availableCards = cardDatabase.getCards(for: difficulty)
            .filter { !usedCards.contains($0.id) }
        
        guard let nextCard = availableCards.randomElement() else {
            endGame()
            return
        }
        
        currentDuo = nextCard
        usedCards.insert(nextCard.id)
        
        // Rotate asker/guesser
        currentAskerIndex = (currentAskerIndex + 1) % players.count
        currentGuesserIndex = (currentGuesserIndex + 1) % players.count
        
        gameState = .playing
    }
    
    public func submitAnswer(_ answer: String) -> Bool {
        guard let duo = currentDuo else { return false }
        
        let isCorrect = Validator.validateAnswer(answer, against: duo.member2)
        
        if isCorrect {
            let points = duo.difficulty
            players[currentGuesserIndex].score += points
            SoundManager.shared.playCorrectSound()
        } else {
            SoundManager.shared.playIncorrectSound()
        }
        
        gameState = .roundComplete
        return isCorrect
    }
    
    public func nextRound() {
        currentRound += 1
        startNewRound()
    }
    
    public func endGame() {
        gameState = .gameOver
    }
    
    public func getLeaderboard() -> [(player: Player, score: Int)] {
        return players
            .map { ($0, $0.score) }
            .sorted { $0.score > $1.score }
    }
    
    public func getWinner() -> Player? {
        return getLeaderboard().first?.player
    }
    
    public func getCurrentAsker() -> Player {
        return players[currentAskerIndex]
    }
    
    public func getCurrentGuesser() -> Player {
        return players[currentGuesserIndex]
    }
    
    public func getCurrentClue() -> String {
        return currentDuo?.member1 ?? ""
    }
    
    public func getCurrentDuo() -> Duo? {
        return currentDuo
    }
}
