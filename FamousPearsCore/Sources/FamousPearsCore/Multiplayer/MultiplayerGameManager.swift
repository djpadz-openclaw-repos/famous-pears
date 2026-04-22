import Foundation

@MainActor
public class MultiplayerGameManager: NSObject, ObservableObject {
    @Published public var gameState: GameState
    @Published public var players: [Player] = []
    @Published public var currentRound = 0
    @Published public var totalRounds = 5
    @Published public var isGameActive = false
    @Published public var error: String?
    @Published public var gamePhase: GamePhase = .waiting
    
    private let networkCoordinator: NetworkCoordinator
    private let gameLogic: GameLogic
    private let validator: Validator
    private let cardDatabase: CardDatabase
    private var localPlayerId: String
    private var playerScores: [String: Int] = [:]
    private var playerRoundsWon: [String: Int] = [:]
    private var currentRoundAnswers: [String: String] = [:]
    
    public enum GamePhase {
        case waiting
        case starting
        case roundActive
        case roundEnded
        case gameEnded
    }
    
    public init(
        displayName: String,
        networkMode: NetworkCoordinator.NetworkMode,
        totalRounds: Int = 5
    ) {
        self.localPlayerId = UUID().uuidString
        self.totalRounds = totalRounds
        self.networkCoordinator = NetworkCoordinator(displayName: displayName, mode: networkMode)
        self.gameLogic = GameLogic()
        self.validator = Validator()
        self.cardDatabase = CardDatabase()
        self.gameState = GameState(
            currentRound: GameRound(clue: "", answer: "", difficulty: 1),
            players: [],
            scores: [:]
        )
        
        super.init()
        observeNetworkMessages()
        addLocalPlayer(name: displayName)
    }
    
    private func addLocalPlayer(name: String) {
        let player = Player(id: localPlayerId, name: name)
        players.append(player)
        playerScores[localPlayerId] = 0
        playerRoundsWon[localPlayerId] = 0
    }
    
    private func observeNetworkMessages() {
        Task {
            for await message in networkCoordinator.$receivedMessage.values {
                if let message = message {
                    await handleNetworkMessage(message)
                }
            }
        }
    }
    
    private func handleNetworkMessage(_ message: NetworkMessage) async {
        switch message {
        case .playerJoined(let playerInfo):
            handlePlayerJoined(playerInfo)
        case .playerLeft(let playerId):
            handlePlayerLeft(playerId)
        case .gameStarted(let gameStart):
            handleGameStarted(gameStart)
        case .roundStarted(let roundStart):
            handleRoundStarted(roundStart)
        case .playerAnswer(let answer):
            await handlePlayerAnswer(answer)
        case .roundEnded(let roundEnd):
            handleRoundEnded(roundEnd)
        case .gameEnded(let gameEnd):
            handleGameEnded(gameEnd)
        case .scoreUpdate(let scoreUpdate):
            handleScoreUpdate(scoreUpdate)
        case .error(let errorMsg):
            self.error = errorMsg
        default:
            break
        }
    }
    
    private func handlePlayerJoined(_ playerInfo: PlayerInfo) {
        let player = Player(id: playerInfo.id, name: playerInfo.name)
        if !players.contains(where: { $0.id == playerInfo.id }) {
            players.append(player)
            playerScores[playerInfo.id] = 0
            playerRoundsWon[playerInfo.id] = 0
        }
    }
    
    private func handlePlayerLeft(_ playerId: String) {
        players.removeAll { $0.id == playerId }
        playerScores.removeValue(forKey: playerId)
        playerRoundsWon.removeValue(forKey: playerId)
    }
    
    private func handleGameStarted(_ gameStart: GameStartMessage) {
        isGameActive = true
        gamePhase = .starting
        currentRound = 0
        players = gameStart.players.map { Player(id: $0.id, name: $0.name) }
    }
    
    private func handleRoundStarted(_ roundStart: RoundStartMessage) {
        currentRound = roundStart.roundNumber
        gamePhase = .roundActive
        let round = GameRound(
            clue: roundStart.clue,
            answer: "",
            difficulty: roundStart.difficulty
        )
        gameState.currentRound = round
    }
    
    private func handlePlayerAnswer(_ answer: AnswerMessage) async {
        // Store the answer for this round
        currentRoundAnswers[answer.playerId] = answer.answer
        
        let isCorrect = validator.validateAnswer(answer.answer, against: gameState.currentRound.answer)
        
        if isCorrect {
            let points = gameLogic.calculatePoints(difficulty: gameState.currentRound.difficulty)
            playerScores[answer.playerId, default: 0] += points
            
            // Send score update
            let scoreMsg = ScoreMessage(
                playerId: answer.playerId,
                playerName: answer.playerName,
                score: playerScores[answer.playerId] ?? 0,
                roundsWon: playerRoundsWon[answer.playerId] ?? 0
            )
            
            do {
                try networkCoordinator.sendMessage(.scoreUpdate(scoreMsg))
            } catch {
                self.error = "Failed to send score update: \(error.localizedDescription)"
            }
        }
    }
    
    private func handleRoundEnded(_ roundEnd: RoundEndMessage) {
        gamePhase = .roundEnded
        
        for playerId in roundEnd.correctPlayers {
            playerRoundsWon[playerId, default: 0] += 1
        }
    }
    
    private func handleGameEnded(_ gameEnd: GameEndMessage) {
        isGameActive = false
        gamePhase = .gameEnded
    }
    
    private func handleScoreUpdate(_ scoreUpdate: ScoreMessage) {
        playerScores[scoreUpdate.playerId] = scoreUpdate.score
        playerRoundsWon[scoreUpdate.playerId] = scoreUpdate.roundsWon
    }
    
    public func startGame() async {
        guard players.count >= 2 else {
            error = "Need at least 2 players to start"
            return
        }
        
        isGameActive = true
        gamePhase = .starting
        
        let playerInfos = players.map { PlayerInfo(id: $0.id, name: $0.name) }
        let gameStartMsg = GameStartMessage(totalRounds: totalRounds, players: playerInfos)
        
        do {
            try networkCoordinator.sendMessage(.gameStarted(gameStartMsg))
        } catch {
            self.error = "Failed to start game: \(error.localizedDescription)"
        }
    }
    
    public func startRound() async {
        guard isGameActive else { return }
        
        // Clear answers from previous round
        currentRoundAnswers.removeAll()
        
        currentRound += 1
        guard currentRound <= totalRounds else {
            await endGame()
            return
        }
        
        guard let duo = cardDatabase.getRandomDuo() else {
            error = "Failed to load card"
            return
        }
        
        let roundMsg = RoundStartMessage(
            roundNumber: currentRound,
            clue: duo.member1,
            difficulty: duo.difficulty
        )
        
        gameState.currentRound = GameRound(
            clue: duo.member1,
            answer: duo.member2,
            difficulty: duo.difficulty
        )
        
        do {
            try networkCoordinator.sendMessage(.roundStarted(roundMsg))
        } catch {
            self.error = "Failed to start round: \(error.localizedDescription)"
        }
    }
    
    public func submitAnswer(_ answer: String) async {
        let answerMsg = AnswerMessage(
            playerId: localPlayerId,
            playerName: players.first(where: { $0.id == localPlayerId })?.name ?? "Unknown",
            answer: answer,
            roundNumber: currentRound
        )
        
        do {
            try networkCoordinator.sendMessage(.playerAnswer(answerMsg))
        } catch {
            self.error = "Failed to submit answer: \(error.localizedDescription)"
        }
    }
    
    public func endRound() async {
        // Determine correct players based on their submitted answers
        var correctPlayers: [String] = []
        var pointsAwarded: [String: Int] = [:]
        
        for (playerId, answer) in currentRoundAnswers {
            if validator.validateAnswer(answer, against: gameState.currentRound.answer) {
                correctPlayers.append(playerId)
                let points = gameLogic.calculatePoints(difficulty: gameState.currentRound.difficulty)
                pointsAwarded[playerId] = points
                playerRoundsWon[playerId, default: 0] += 1
            }
        }
        
        let roundEndMsg = RoundEndMessage(
            roundNumber: currentRound,
            correctAnswer: gameState.currentRound.answer,
            correctPlayers: correctPlayers,
            pointsAwarded: pointsAwarded
        )
        
        do {
            try networkCoordinator.sendMessage(.roundEnded(roundEndMsg))
        } catch {
            self.error = "Failed to end round: \(error.localizedDescription)"
        }
    }
    
    private func endGame() async {
        let winnerId = playerScores.max(by: { $0.value < $1.value })?.key ?? localPlayerId
        let winner = players.first(where: { $0.id == winnerId }) ?? Player(id: winnerId, name: "Unknown")
        let winnerInfo = PlayerInfo(id: winner.id, name: winner.name)
        
        let gameEndMsg = GameEndMessage(
            winner: winnerInfo,
            finalScores: playerScores
        )
        
        do {
            try networkCoordinator.sendMessage(.gameEnded(gameEndMsg))
        } catch {
            self.error = "Failed to end game: \(error.localizedDescription)"
        }
    }
    
    public func disconnect() {
        networkCoordinator.disconnect()
        isGameActive = false
        gamePhase = .waiting
    }
}
