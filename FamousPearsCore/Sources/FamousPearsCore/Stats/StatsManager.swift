import Foundation

public struct GameStats: Codable {
    public let playerId: String
    public let playerName: String
    public let gamesPlayed: Int
    public let gamesWon: Int
    public let totalScore: Int
    public let averageScore: Double
    public let correctAnswers: Int
    public let totalAnswers: Int
    public let accuracy: Double
    public let longestWinStreak: Int
    public let currentWinStreak: Int
    public let lastPlayedDate: Date
    public let joinedDate: Date
    
    public var winRate: Double {
        gamesPlayed > 0 ? Double(gamesWon) / Double(gamesPlayed) : 0
    }
}

public class StatsManager: ObservableObject {
    @Published public var playerStats: [String: GameStats] = [:]
    @Published public var leaderboard: [GameStats] = []
    
    private let fileManager = FileManager.default
    private let statsDirectory: URL
    
    public init() {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        statsDirectory = paths[0].appendingPathComponent("FamousPearsStats")
        
        try? fileManager.createDirectory(at: statsDirectory, withIntermediateDirectories: true)
        loadAllStats()
    }
    
    public func recordGameResult(
        playerId: String,
        playerName: String,
        score: Int,
        correctAnswers: Int,
        totalAnswers: Int,
        won: Bool
    ) {
        var stats = playerStats[playerId] ?? GameStats(
            playerId: playerId,
            playerName: playerName,
            gamesPlayed: 0,
            gamesWon: 0,
            totalScore: 0,
            averageScore: 0,
            correctAnswers: 0,
            totalAnswers: 0,
            accuracy: 0,
            longestWinStreak: 0,
            currentWinStreak: 0,
            lastPlayedDate: Date(),
            joinedDate: Date()
        )
        
        let newGamesPlayed = stats.gamesPlayed + 1
        let newGamesWon = stats.gamesWon + (won ? 1 : 0)
        let newTotalScore = stats.totalScore + score
        let newCorrectAnswers = stats.correctAnswers + correctAnswers
        let newTotalAnswers = stats.totalAnswers + totalAnswers
        
        let newStats = GameStats(
            playerId: playerId,
            playerName: playerName,
            gamesPlayed: newGamesPlayed,
            gamesWon: newGamesWon,
            totalScore: newTotalScore,
            averageScore: Double(newTotalScore) / Double(newGamesPlayed),
            correctAnswers: newCorrectAnswers,
            totalAnswers: newTotalAnswers,
            accuracy: newTotalAnswers > 0 ? Double(newCorrectAnswers) / Double(newTotalAnswers) : 0,
            longestWinStreak: won ? max(stats.longestWinStreak, stats.currentWinStreak + 1) : stats.longestWinStreak,
            currentWinStreak: won ? stats.currentWinStreak + 1 : 0,
            lastPlayedDate: Date(),
            joinedDate: stats.joinedDate
        )
        
        playerStats[playerId] = newStats
        saveStats(newStats)
        updateLeaderboard()
    }
    
    public func getPlayerStats(playerId: String) -> GameStats? {
        playerStats[playerId]
    }
    
    public func getLeaderboard(sortBy: LeaderboardSort = .totalScore) -> [GameStats] {
        switch sortBy {
        case .totalScore:
            return leaderboard.sorted { $0.totalScore > $1.totalScore }
        case .winRate:
            return leaderboard.sorted { $0.winRate > $1.winRate }
        case .accuracy:
            return leaderboard.sorted { $0.accuracy > $1.accuracy }
        case .gamesPlayed:
            return leaderboard.sorted { $0.gamesPlayed > $1.gamesPlayed }
        case .averageScore:
            return leaderboard.sorted { $0.averageScore > $1.averageScore }
        }
    }
    
    public enum LeaderboardSort {
        case totalScore
        case winRate
        case accuracy
        case gamesPlayed
        case averageScore
    }
    
    private func updateLeaderboard() {
        leaderboard = Array(playerStats.values)
    }
    
    private func saveStats(_ stats: GameStats) {
        let filename = "\(stats.playerId).json"
        let fileURL = statsDirectory.appendingPathComponent(filename)
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(stats)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save stats: \(error)")
        }
    }
    
    private func loadAllStats() {
        do {
            let files = try fileManager.contentsOfDirectory(at: statsDirectory, includingPropertiesForKeys: nil)
            
            for file in files where file.pathExtension == "json" {
                do {
                    let data = try Data(contentsOf: file)
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let stats = try decoder.decode(GameStats.self, from: data)
                    playerStats[stats.playerId] = stats
                } catch {
                    print("Failed to load stats from \(file): \(error)")
                }
            }
            
            updateLeaderboard()
        } catch {
            print("Failed to load stats directory: \(error)")
        }
    }
    
    public func clearAllStats() {
        playerStats.removeAll()
        leaderboard.removeAll()
        
        do {
            let files = try fileManager.contentsOfDirectory(at: statsDirectory, includingPropertiesForKeys: nil)
            for file in files {
                try fileManager.removeItem(at: file)
            }
        } catch {
            print("Failed to clear stats: \(error)")
        }
    }
}
