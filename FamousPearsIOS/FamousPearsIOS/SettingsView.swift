import SwiftUI
import FamousPearsCore

struct SettingsView: View {
    @AppStorage("gameMode") private var gameMode: String = GameMode.mixed.rawValue
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("totalRounds") private var totalRounds = 5
    @AppStorage("showHints") private var showHints = true
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Game Settings") {
                    Picker("Difficulty Mode", selection: $gameMode) {
                        ForEach(GameMode.allCases, id: \.self) { mode in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(mode.displayName)
                                Text(mode.description)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .tag(mode.rawValue)
                        }
                    }
                    
                    Stepper("Rounds per Game: \(totalRounds)", value: $totalRounds, in: 3...10)
                    
                    Toggle("Show Hints", isOn: $showHints)
                }
                
                Section("Audio & Visuals") {
                    Toggle("Sound Effects", isOn: $soundEnabled)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Total Cards")
                        Spacer()
                        Text("110")
                            .foregroundColor(.gray)
                    }
                }
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

#Preview {
    SettingsView()
}
