import SwiftUI
import FamousPearsCore

@main
struct FamousPearsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(GameKitManager.shared)
                .environmentObject(MultipeerManager.shared)
        }
    }
}
