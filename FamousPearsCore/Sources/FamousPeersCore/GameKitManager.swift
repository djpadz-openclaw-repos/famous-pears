import GameKit
import Foundation
import Combine
import os.log

public class GameKitManager: NSObject, GKMatchDelegate, GKMatchmakerViewControllerDelegate, ObservableObject {
    public static let shared = GameKitManager()
    
    @Published public var match: GKMatch?
    @Published public var isAuthenticated = false
    @Published public var localPlayer: GKLocalPlayer?
    
    override init() {
        super.init()
        authenticateLocalPlayer()
    }
    
    private func authenticateLocalPlayer() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            if let error = error {
                os_log("[GameKitManager] Authentication error: %{public}@", log: OSLog.default, type: .error, error.localizedDescription)
                return
            }
            
            if GKLocalPlayer.local.isAuthenticated {
                os_log("[GameKitManager] Player authenticated: %{public}@", log: OSLog.default, type: .info, GKLocalPlayer.local.displayName)
                self?.isAuthenticated = true
                self?.localPlayer = GKLocalPlayer.local
            }
        }
    }
    
    public func startMatchmaking(minPlayers: Int = 2, maxPlayers: Int = 4, presentingViewController: UIViewController) {
        guard GKLocalPlayer.local.isAuthenticated else {
            os_log("[GameKitManager] Local player not authenticated", log: OSLog.default, type: .error)
            return
        }
        
        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers
        request.defaultNumberOfPlayers = 2
        
        os_log("[GameKitManager] Starting matchmaking with min=%d max=%d", log: OSLog.default, type: .info, minPlayers, maxPlayers)
        
        let matchmakerViewController = GKMatchmakerViewController(matchRequest: request)
        matchmakerViewController?.matchmakerDelegate = self
        presentingViewController.present(matchmakerViewController ?? UIViewController(), animated: true)
    }
    
    public func disconnect() {
        match?.disconnect()
        match = nil
    }
    
    // MARK: - GKMatchDelegate
    
    public func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        os_log("[GameKitManager] Received data from player: %{public}@", log: OSLog.default, type: .info, player.displayName)
    }
    
    public func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        os_log("[GameKitManager] Player %{public}@ changed state: %d", log: OSLog.default, type: .info, player.displayName, state.rawValue)
    }
    
    public func match(_ match: GKMatch, didFailWithError error: Error?) {
        os_log("[GameKitManager] Match error: %{public}@", log: OSLog.default, type: .error, error?.localizedDescription ?? "Unknown")
    }
    
    // MARK: - GKMatchmakerViewControllerDelegate
    
    public func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        os_log("[GameKitManager] Match found with %d players", log: OSLog.default, type: .info, match.players.count)
        self.match = match
        match.delegate = self
        viewController.dismiss(animated: true)
    }
    
    public func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        os_log("[GameKitManager] Matchmaking cancelled", log: OSLog.default, type: .info)
        viewController.dismiss(animated: true)
    }
    
    public func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        os_log("[GameKitManager] Matchmaker error: %{public}@", log: OSLog.default, type: .error, error.localizedDescription)
        viewController.dismiss(animated: true)
    }
}
