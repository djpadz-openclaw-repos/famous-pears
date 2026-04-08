import Foundation
import GameKit

@MainActor
public class GameKitManager: NSObject, ObservableObject {
    @Published public var isAuthenticated = false
    @Published public var connectedPlayers: [GKPlayer] = []
    @Published public var matchStarted = false
    @Published public var receivedData: Data?
    @Published public var error: String?
    
    private var match: GKMatch?
    private var localPlayer: GKLocalPlayer?
    
    public override init() {
        super.init()
        authenticateLocalPlayer()
    }
    
    private func authenticateLocalPlayer() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            guard let self = self else { return }
            
            if let error = error {
                self.error = "GameKit auth failed: \(error.localizedDescription)"
                return
            }
            
            if let viewController = viewController {
                // Present auth UI if needed
                DispatchQueue.main.async {
                    self.error = "GameKit auth UI needed"
                }
                return
            }
            
            if GKLocalPlayer.local.isAuthenticated {
                self.localPlayer = GKLocalPlayer.local
                self.isAuthenticated = true
            }
        }
    }
    
    public func startMatchmaking(minPlayers: Int = 2, maxPlayers: Int = 4) {
        guard isAuthenticated else {
            error = "Not authenticated with GameKit"
            return
        }
        
        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers
        
        GKMatchmaker.shared().findMatch(for: request) { [weak self] match, error in
            guard let self = self else { return }
            
            if let error = error {
                self.error = "Matchmaking failed: \(error.localizedDescription)"
                return
            }
            
            guard let match = match else {
                self.error = "No match found"
                return
            }
            
            self.match = match
            match.delegate = self
            self.connectedPlayers = match.players
            self.matchStarted = true
        }
    }
    
    public func sendData(_ data: Data, to players: [GKPlayer]? = nil) throws {
        guard let match = match else {
            throw NSError(domain: "GameKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No active match"])
        }
        
        let recipients = players ?? match.players
        try match.send(data, to: recipients, dataMode: .reliable)
    }
    
    public func disconnect() {
        match?.disconnect()
        match = nil
        matchStarted = false
        connectedPlayers = []
    }
}

extension GameKitManager: GKMatchDelegate {
    public func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        DispatchQueue.main.async {
            self.receivedData = data
        }
    }
    
    public func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        DispatchQueue.main.async {
            self.connectedPlayers = match.players
            
            if state == .disconnected {
                self.error = "Player disconnected: \(player.displayName)"
            }
        }
    }
    
    public func match(_ match: GKMatch, didFailWithError error: Error?) {
        DispatchQueue.main.async {
            self.error = "Match error: \(error?.localizedDescription ?? "Unknown")"
            self.matchStarted = false
        }
    }
}
