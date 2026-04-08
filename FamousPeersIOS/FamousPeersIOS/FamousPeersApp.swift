import SwiftUI
import FamousPeersCore

@main
struct FamousPeersApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(GameKitManager.shared)
                .environmentObject(MultipeerManager.shared)
        }
    }
}
