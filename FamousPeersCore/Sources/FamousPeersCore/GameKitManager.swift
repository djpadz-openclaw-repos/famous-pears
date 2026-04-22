import GameKit
import Foundation
import Combine
import os.log

public protocol GameKitManagerDelegate: AnyObject {
    func gameKitManager(_ manager: GameKitManager, didReceiveMessage data: Data, from player: GKPlayer)
    func gameKitManager(_ manager: GameKitManager, playerConnected player: GKPlayer)
    func gameKitManager(_ manager: GameKitManager, playerDisconnected player: GKPlayer)
}

public class GameKitManager: NSObject, GKMatchDelegate, GKMatchmakerViewControllerDelegate, ObservableObject {
    public static let shared = GameKitManager()
    
    public weak var delegate: GameKitManagerDelegate?
    public var match: GKMatch?
    public var localPlayer: GKPlayer?
    
    public override init() {
        super.init()
        authenticateLocalPlayer()
    }
    
    private func authenticateLocalPlayer() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            if let error = error {
                print("GameKit authentication error: \(error)")
                return
            }
            
            if viewController != nil {
                // Present authentication UI if needed
                print("GameKit authentication required")
            }
            
            self?.localPlayer = GKLocalPlayer.local
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
    
    public func sendMessage(_ data: Data, to players: [GKPlayer]? = nil) {
        guard let match = match else { return }
        
        do {
            try match.send(data, to: players ?? [], dataMode: .reliable)
        } catch {
            print("Error sending GameKit message: \(error)")
        }
    }
    
    public func disconnect() {
        match?.disconnect()
        match = nil
    }
    
    // MARK: - GKMatchDelegate
    
    public func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        delegate?.gameKitManager(self, didReceiveMessage: data, from: player)
    }
    
    public func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        switch state {
        case .connected:
            delegate?.gameKitManager(self, playerConnected: player)
        case .disconnected:
            delegate?.gameKitManager(self, playerDisconnected: player)
        case .unknown:
            break
        @unknown default:
            break
        }
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
