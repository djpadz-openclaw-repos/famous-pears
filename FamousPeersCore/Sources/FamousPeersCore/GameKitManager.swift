import GameKit
import Foundation

public protocol GameKitManagerDelegate: AnyObject {
    func gameKitManager(_ manager: GameKitManager, didReceiveMessage data: Data, from player: GKPlayer)
    func gameKitManager(_ manager: GameKitManager, playerConnected player: GKPlayer)
    func gameKitManager(_ manager: GameKitManager, playerDisconnected player: GKPlayer)
}

public class GameKitManager: NSObject, GKMatchDelegate {
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
            
            if let viewController = viewController {
                // Present authentication UI if needed
                print("GameKit authentication required")
            }
            
            self?.localPlayer = GKLocalPlayer.local
        }
    }
    
    public func startMatchmaking(minPlayers: Int = 2, maxPlayers: Int = 4) {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("Local player not authenticated")
            return
        }
        
        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers
        print("Starting matchmaking")
    }
    
    public func sendMessage(_ data: Data, to players: [GKPlayer]? = nil) {
        guard let match = match else { return }
        
        do {
            try match.send(data, to: players, dataMode: .reliable)
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
        print("GameKit match error: \(error?.localizedDescription ?? "Unknown")")
    }
}
