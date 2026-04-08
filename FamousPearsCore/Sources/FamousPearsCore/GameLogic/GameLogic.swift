import Foundation

public class GameLogic {
    public var players: [Player]
    public var currentRound: GameRound?
    public var state: GameState = .setup
    public var rounds: [GameRound] = []
    public var difficultyMode: DifficultyMode = .mixed
    public var maxRounds: Int = 10
    
    private var cardDatabase = CardDatabase.shared
    private var usedCardIds: Set<Int> = []
    private var availableCards: [Duo] = []
    
    public init(players: [Player], difficulty: DifficultyMode = .mixed) {
        self.players = players
        self.difficultyMode = difficulty
    }
    
    public func startGame() {
        state = .playing
        usedCardIds.removeAll()
        rounds.removeAll()
        filterCardsByDifficulty()
    }
    
    private func filterCardsByDifficulty() {
        let range = difficultyMode.pointRange
        availableCards = cardDatabase.getAllCards().filter { range.contains($0.difficulty) }
    }
    
    public func startNewRound(askerIndex: Int) -> GameRound? {
        guard askerIndex < players.count else { return nil }
        guard rounds.count < maxRounds else {
            endGame()
            return nil
        }
        
        let asker = players[askerIndex]
        let guesserIndex = (askerIndex + 1) % players.count
        let guesser = players[guesserIndex]
        
        guard let duo = getUnusedCard() else {
            endGame()
            return nil
        }
        
        usedCardIds.insert(duo.id)
        
        // Randomly pick which member to read
        let readMember = duo.getRandomMember()
        let correctAnswer = duo.getOtherMember(readMember)
        
        let round = GameRound(
            duoId: duo.id,
            asker: asker,
            guesser: guesser,
            duoName: duo.duoName,
            readMember: readMember,
            correctAnswer: correctAnswer
        )
        currentRound = round
        state = .playing
        
        return round
    }
    
    public func submitAnswer(_ answer: String) -> Bool {
        guard let round = currentRound else { return false }
        
        let isCorrect = Validator.checkAnswer(answer, against: round.correctAnswer)
        currentRound?.submittedAnswer = answer
        currentRound?.isCorrect = isCorrect
        
        if isCorrect {
            guard let duo = cardDatabase.getCard(id: round.duoId) else { return false }
            let points = duo.difficulty
            currentRound?.pointsAwarded = points
            
            if let guesserIndex = players.firstIndex(where: { $0.id == round.guesser.id }) {
                players[guesserIndex].score += points
            }
        }
        
        if let round = currentRound {
            rounds.append(round)
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
    
    public func isGameOver() -> Bool {
        rounds.count >= maxRounds
    }
    
    private func getUnusedCard() -> Duo? {
        availableCards.first { !usedCardIds.contains($0.id) }
    }
}
