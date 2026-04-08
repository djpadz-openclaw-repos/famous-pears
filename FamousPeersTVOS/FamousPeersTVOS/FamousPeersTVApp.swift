import SwiftUI
import FamousPeersCore

@main
struct FamousPeersTVApp: App {
    var body: some Scene {
        WindowGroup {
            TVContentView()
                .environmentObject(MultipeerManager.shared)
        }
    }
}
