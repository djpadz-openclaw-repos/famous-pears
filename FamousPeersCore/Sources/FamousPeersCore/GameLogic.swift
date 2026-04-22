import Foundation
import Combine

public class GameLogic: ObservableObject {
    @Published public var players: [Player]
    @Published public var currentRound: Int = 0
    @Published public var gameState: GameState = .setup
    public var difficulty: DifficultyMode = .mixed
    
    private let cardDatabase = CardDatabase()
    private var usedCards: Set<Int> = []
    private var currentDuo: Duo?
    private var currentAskerIndex: Int = 0
    private var currentGuesserIndex: Int = 1
    private var aiManager: AIManager?
    
    public init(players: [Player], difficulty: DifficultyMode = .mixed) {
        self.players = players
        self.difficulty = difficulty
        
        // Initialize AI manager based on difficulty
        let aiDifficulty: AIManager.Difficulty
        switch difficulty {
        case .easy:
            aiDifficulty = .easy
        case .medium:
            aiDifficulty = .medium
        case .hard:
            aiDifficulty = .hard
        case .mixed:
            aiDifficulty = .medium
        }
        self.aiManager = AIManager(difficulty: aiDifficulty)
    }
    
    public func startGame() {
        gameState = .playing
        currentRound = 1
        startNewRound()
    }
    
    public func startNewRound() {
        guard players.count >= 2 else { return }
        
        // Get next card using weighted random selection
        guard let nextCard = cardDatabase.getWeightedRandomCard(for: difficulty, excluding: usedCards) else {
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
        return currentDuo?.hint ?? ""
    }
    
    public func getCurrentDuo() -> Duo? {
        return currentDuo
    }
    
    // MARK: - AI Player Support
    
    public func isComputerPlayer(_ player: Player) -> Bool {
        return player.name == "Computer"
    }
    
    public func getComputerClue() -> String {
        guard let duo = currentDuo, let aiManager = aiManager else { return "" }
        return aiManager.generateClue(for: duo.member1, hint: duo.hint)
    }
    
    public func getComputerGuess(possibleAnswers: [String]) -> String {
        guard let aiManager = aiManager else { return "" }
        return aiManager.makeGuess(givenClue: getCurrentClue(), possibleAnswers: possibleAnswers)
    }
    
    public func getCurrentAskerIsComputer() -> Bool {
        return isComputerPlayer(getCurrentAsker())
    }
    
    public func getCurrentGuesserIsComputer() -> Bool {
        return isComputerPlayer(getCurrentGuesser())
    }
    
    public func getPossibleAnswers(count: Int = 3) -> [String] {
        guard let currentDuo = currentDuo else { return [] }
        
        // Start with the correct answer
        var answers = [currentDuo.member2]
        
        // Get random distractors from other duos
        let allCards = cardDatabase.getAllCards()
        let otherCards = allCards.filter { $0.id != currentDuo.id }
        
        for _ in 0..<(count - 1) {
            if let randomCard = otherCards.randomElement() {
                answers.append(randomCard.member2)
            }
        }
        
        return answers.shuffled()
    }
}
