import SwiftUI

public struct TriviaView: View {
    let duo: Duo
    let onContinue: () -> Void
    
    public init(duo: Duo, onContinue: @escaping () -> Void) {
        self.duo = duo
        self.onContinue = onContinue
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("Did You Know?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                Text(duo.duoName)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            VStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.yellow)
                
                Text(duo.trivia ?? "No trivia available for this duo.")
                    .font(.body)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            
            Spacer()
            
            Button(action: onContinue) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

#Preview {
    TriviaView(
        duo: Duo(
            id: 1,
            uuid: "test-uuid",
            category: "music",
            duoName: "The Beatles",
            members: [[AnyCodable.string("John Lennon")], [AnyCodable.string("Paul McCartney")]],
            difficulty: 1,
            hint: "Legendary rock band",
            trivia: "They were the first rock band to win a Grammy Award for Best New Artist in 1965."
        ),
        onContinue: {}
    )
}
