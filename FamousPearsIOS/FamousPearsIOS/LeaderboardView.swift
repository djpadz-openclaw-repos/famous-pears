import SwiftUI
import FamousPearsCore

struct LeaderboardView: View {
    @StateObject private var statsManager = StatsManager()
    @State private var sortBy: StatsManager.LeaderboardSort = .totalScore
    
    var sortedLeaderboard: [GameStats] {
        statsManager.getLeaderboard(sortBy: sortBy)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Sort By", selection: $sortBy) {
                    Text("Total Score").tag(StatsManager.LeaderboardSort.totalScore)
                    Text("Win Rate").tag(StatsManager.LeaderboardSort.winRate)
                    Text("Accuracy").tag(StatsManager.LeaderboardSort.accuracy)
                    Text("Games Played").tag(StatsManager.LeaderboardSort.gamesPlayed)
                    Text("Avg Score").tag(StatsManager.LeaderboardSort.averageScore)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if sortedLeaderboard.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text("No Stats Yet")
                            .font(.headline)
                        
                        Text("Play a game to see your stats here")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                    .padding()
                } else {
                    List {
                        ForEach(Array(sortedLeaderboard.enumerated()), id: \.element.playerId) { index, stats in
                            LeaderboardRowView(stats: stats, rank: index + 1)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct LeaderboardRowView: View {
    let stats: GameStats
    let rank: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(rankColor)
                        .frame(width: 40, height: 40)
                    
                    Text("\(rank)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(stats.playerName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 12) {
                        Label("\(stats.gamesPlayed)", systemImage: "gamecontroller.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Label("\(stats.gamesWon)W", systemImage: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(stats.totalScore)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text(String(format: "%.1f%%", stats.accuracy * 100))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 8)
            
            HStack(spacing: 16) {
                StatBadge(label: "Avg", value: String(format: "%.0f", stats.averageScore))
                StatBadge(label: "Win Rate", value: String(format: "%.0f%%", stats.winRate * 100))
                StatBadge(label: "Streak", value: "\(stats.currentWinStreak)")
                
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }
}

struct StatBadge: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(6)
    }
}

struct PlayerStatsDetailView: View {
    let stats: GameStats
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.blue)
                        
                        Text(stats.playerName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Member since \(stats.joinedDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    VStack(spacing: 16) {
                        StatRow(label: "Games Played", value: "\(stats.gamesPlayed)")
                        StatRow(label: "Games Won", value: "\(stats.gamesWon)")
                        StatRow(label: "Win Rate", value: String(format: "%.1f%%", stats.winRate * 100))
                        StatRow(label: "Total Score", value: "\(stats.totalScore)")
                        StatRow(label: "Average Score", value: String(format: "%.1f", stats.averageScore))
                        StatRow(label: "Accuracy", value: String(format: "%.1f%%", stats.accuracy * 100))
                        StatRow(label: "Correct Answers", value: "\(stats.correctAnswers)/\(stats.totalAnswers)")
                        StatRow(label: "Current Win Streak", value: "\(stats.currentWinStreak)")
                        StatRow(label: "Longest Win Streak", value: "\(stats.longestWinStreak)")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Player Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    LeaderboardView()
}
