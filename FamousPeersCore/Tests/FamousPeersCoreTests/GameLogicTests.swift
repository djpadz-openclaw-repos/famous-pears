import XCTest
@testable import FamousPeersCore

final class GameLogicTests: XCTestCase {
    
    var gameLogic: GameLogic!
    var player1: Player!
    var player2: Player!
    
    override func setUp() {
        super.setUp()
        player1 = Player(name: "Alice")
        player2 = Player(name: "Bob")
        gameLogic = GameLogic(players: [player1, player2], difficulty: .mixed)
    }
    
    // MARK: - Game Initialization Tests
    
    func testGameInitialization() {
        XCTAssertEqual(gameLogic.players.count, 2)
        XCTAssertEqual(gameLogic.state, .setup)
        XCTAssertEqual(gameLogic.rounds.count, 0)
        XCTAssertNil(gameLogic.currentRound)
    }
    
    func testGameStart() {
        gameLogic.startGame()
        XCTAssertEqual(gameLogic.state, .playing)
        XCTAssertEqual(gameLogic.rounds.count, 0)
    }
    
    // MARK: - Round Management Tests
    
    func testStartNewRound() {
        gameLogic.startGame()
        let round = gameLogic.startNewRound(askerIndex: 0)
        
        XCTAssertNotNil(round)
        XCTAssertEqual(round?.asker.name, "Alice")
        XCTAssertEqual(round?.guesser.name, "Bob")
        XCTAssertNotNil(round?.duoName)
        XCTAssertNotNil(round?.readMember)
        XCTAssertNotNil(round?.correctAnswer)
    }
    
    func testRoundAlternatesPlayers() {
        gameLogic.startGame()
        
        let round1 = gameLogic.startNewRound(askerIndex: 0)
        XCTAssertEqual(round1?.asker.name, "Alice")
        XCTAssertEqual(round1?.guesser.name, "Bob")
        
        // Simulate answer submission to move to next round
        _ = gameLogic.submitAnswer("dummy")
        
        let round2 = gameLogic.startNewRound(askerIndex: 1)
        XCTAssertEqual(round2?.asker.name, "Bob")
        XCTAssertEqual(round2?.guesser.name, "Alice")
    }
    
    func testInvalidAskerIndex() {
        gameLogic.startGame()
        let round = gameLogic.startNewRound(askerIndex: 5)
        XCTAssertNil(round)
    }
    
    // MARK: - Answer Submission Tests
    
    func testCorrectAnswer() {
        gameLogic.startGame()
        _ = gameLogic.startNewRound(askerIndex: 0)
        
        guard let round = gameLogic.currentRound else {
            XCTFail("No current round")
            return
        }
        
        let isCorrect = gameLogic.submitAnswer(round.correctAnswer)
        XCTAssertTrue(isCorrect)
        XCTAssertTrue(gameLogic.currentRound?.isCorrect ?? false)
    }
    
    func testIncorrectAnswer() {
        gameLogic.startGame()
        _ = gameLogic.startNewRound(askerIndex: 0)
        
        let isCorrect = gameLogic.submitAnswer("Wrong Answer")
        XCTAssertFalse(isCorrect)
        XCTAssertFalse(gameLogic.currentRound?.isCorrect ?? true)
    }
    
    func testAnswerWithTypo() {
        gameLogic.startGame()
        _ = gameLogic.startNewRound(askerIndex: 0)
        
        guard let round = gameLogic.currentRound else {
            XCTFail("No current round")
            return
        }
        
        // Simulate a typo (one character different)
        let answerWithTypo = round.correctAnswer.dropLast() + "x"
        let isCorrect = gameLogic.submitAnswer(String(answerWithTypo))
        XCTAssertTrue(isCorrect)
    }
    
    // MARK: - Scoring Tests
    
    func testPointsAwardedForCorrectAnswer() {
        gameLogic.startGame()
        _ = gameLogic.startNewRound(askerIndex: 0)
        
        guard let round = gameLogic.currentRound else {
            XCTFail("No current round")
            return
        }
        
        let pointsIfCorrect = round.pointsIfCorrect
        _ = gameLogic.submitAnswer(round.correctAnswer)
        
        XCTAssertEqual(gameLogic.currentRound?.pointsAwarded, pointsIfCorrect)
    }
    
    func testNoPointsForIncorrectAnswer() {
        gameLogic.startGame()
        _ = gameLogic.startNewRound(askerIndex: 0)
        
        _ = gameLogic.submitAnswer("Wrong Answer")
        
        XCTAssertEqual(gameLogic.currentRound?.pointsAwarded, 0)
    }
    
    func testPlayerScoreIncremented() {
        gameLogic.startGame()
        let initialScore = player2.score
        
        _ = gameLogic.startNewRound(askerIndex: 0)
        guard let round = gameLogic.currentRound else {
            XCTFail("No current round")
            return
        }
        
        _ = gameLogic.submitAnswer(round.correctAnswer)
        
        let guesserIndex = gameLogic.players.firstIndex { $0.id == player2.id }!
        XCTAssertGreater(gameLogic.players[guesserIndex].score, initialScore)
    }
    
    // MARK: - Game Over Tests
    
    func testGameOverAfterMaxRounds() {
        gameLogic.startGame()
        
        for i in 0..<gameLogic.maxRounds {
            _ = gameLogic.startNewRound(askerIndex: i % 2)
            guard let round = gameLogic.currentRound else { continue }
            _ = gameLogic.submitAnswer(round.correctAnswer)
        }
        
        XCTAssertTrue(gameLogic.isGameOver())
        XCTAssertEqual(gameLogic.state, .gameOver)
    }
    
    func testNoNewRoundAfterGameOver() {
        gameLogic.startGame()
        
        for i in 0..<gameLogic.maxRounds {
            _ = gameLogic.startNewRound(askerIndex: i % 2)
            guard let round = gameLogic.currentRound else { continue }
            _ = gameLogic.submitAnswer(round.correctAnswer)
        }
        
        let round = gameLogic.startNewRound(askerIndex: 0)
        XCTAssertNil(round)
    }
    
    // MARK: - Leaderboard Tests
    
    func testLeaderboardSorting() {
        gameLogic.startGame()
        
        // Manually set scores for testing
        gameLogic.players[0].score = 10
        gameLogic.players[1].score = 20
        
        let leaderboard = gameLogic.getLeaderboard()
        XCTAssertEqual(leaderboard[0].name, "Bob")
        XCTAssertEqual(leaderboard[1].name, "Alice")
    }
    
    func testLeaderboardWithTiedScores() {
        gameLogic.startGame()
        
        gameLogic.players[0].score = 15
        gameLogic.players[1].score = 15
        
        let leaderboard = gameLogic.getLeaderboard()
        XCTAssertEqual(leaderboard.count, 2)
        XCTAssertEqual(leaderboard[0].score, 15)
        XCTAssertEqual(leaderboard[1].score, 15)
    }
    
    // MARK: - Difficulty Mode Tests
    
    func testDifficultyModeEasy() {
        gameLogic = GameLogic(players: [player1, player2], difficulty: .easy)
        gameLogic.startGame()
        
        // Should only have cards with 1-2 point answers
        for _ in 0..<5 {
            _ = gameLogic.startNewRound(askerIndex: 0)
            guard let round = gameLogic.currentRound else { continue }
            XCTAssertLessThanOrEqual(round.pointsIfCorrect, 2)
            _ = gameLogic.submitAnswer("dummy")
        }
    }
    
    func testDifficultyModeHard() {
        gameLogic = GameLogic(players: [player1, player2], difficulty: .hard)
        gameLogic.startGame()
        
        // Should only have cards with 3-5 point answers
        for _ in 0..<5 {
            _ = gameLogic.startNewRound(askerIndex: 0)
            guard let round = gameLogic.currentRound else { continue }
            XCTAssertGreaterThanOrEqual(round.pointsIfCorrect, 3)
            _ = gameLogic.submitAnswer("dummy")
        }
    }
    
    // MARK: - Round Tracking Tests
    
    func testRoundsTracked() {
        gameLogic.startGame()
        
        for i in 0..<3 {
            _ = gameLogic.startNewRound(askerIndex: i % 2)
            guard let round = gameLogic.currentRound else { continue }
            _ = gameLogic.submitAnswer(round.correctAnswer)
            
            XCTAssertEqual(gameLogic.rounds.count, i + 1)
        }
    }
    
    func testRoundDataPreserved() {
        gameLogic.startGame()
        _ = gameLogic.startNewRound(askerIndex: 0)
        
        guard let round = gameLogic.currentRound else {
            XCTFail("No current round")
            return
        }
        
        let duoName = round.duoName
        let readMember = round.readMember
        
        _ = gameLogic.submitAnswer(round.correctAnswer)
        
        let completedRound = gameLogic.rounds.last
        XCTAssertEqual(completedRound?.duoName, duoName)
        XCTAssertEqual(completedRound?.readMember, readMember)
    }
}
