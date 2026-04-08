import SwiftUI
import FamousPearsCore

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var soundManager = SoundManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                List {
                    Section("Audio & Haptics") {
                        Toggle("Sound Effects", isOn: $soundManager.isSoundEnabled)
                            .onChange(of: soundManager.isSoundEnabled) { _, enabled in
                                if enabled {
                                    soundManager.playCorrectSound()
                                }
                            }
                        
                        Toggle("Haptic Feedback", isOn: $soundManager.isHapticsEnabled)
                            .onChange(of: soundManager.isHapticsEnabled) { _, enabled in
                                if enabled {
                                    soundManager.triggerImpact(.light)
                                }
                            }
                    }
                    
                    Section("Game Settings") {
                        NavigationLink(destination: GameRulesView()) {
                            HStack {
                                Image(systemName: "book.fill")
                                Text("How to Play")
                            }
                        }
                    }
                    
                    Section("About") {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.gray)
                        }
                        
                        Link(destination: URL(string: "https://github.com/djpadz-openclaw-repos/famous-pears")!) {
                            HStack {
                                Image(systemName: "link")
                                Text("GitHub Repository")
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Settings")
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

struct GameRulesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("How to Play")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Famous Pears is a multiplayer guessing game where players try to name famous duos.")
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Game Flow")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 12) {
                            Text("1.")
                                .fontWeight(.bold)
                            Text("One player is shown a famous duo and reads the first member aloud")
                        }
                        
                        HStack(alignment: .top, spacing: 12) {
                            Text("2.")
                                .fontWeight(.bold)
                            Text("The other player has to guess the second member")
                        }
                        
                        HStack(alignment: .top, spacing: 12) {
                            Text("3.")
                                .fontWeight(.bold)
                            Text("Correct answers earn points based on difficulty")
                        }
                        
                        HStack(alignment: .top, spacing: 12) {
                            Text("4.")
                                .fontWeight(.bold)
                            Text("Players take turns until all rounds are complete")
                        }
                    }
                    .font(.subheadline)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Difficulty Levels")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Easy")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("1-2 points")
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Text("Medium")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("2-3 points")
                                .foregroundColor(.orange)
                        }
                        
                        HStack {
                            Text("Hard")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("4-5 points")
                                .foregroundColor(.red)
                        }
                    }
                    .font(.subheadline)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("How to Play")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
}
