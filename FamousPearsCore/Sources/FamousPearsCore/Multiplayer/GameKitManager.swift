import Foundation
import GameKit
import os.log

private let logger = Logger(subsystem: "com.famous-peers.gamekit", category: "GameKitManager")

@MainActor
public class GameKitManager: NSObject, ObservableObject {
    @Published public var isAuthenticated = false
    @Published public var connectedPlayers: [GKPlayer] = []
    @Published public var matchStarted = false
    @Published public var receivedData: Data?
    @Published public var error: String?
    @Published public var matchmakerViewController: GKMatchmakerViewController?
    
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
                let errorMsg = "GameKit auth failed: \(error.localizedDescription)"
                logger.error("\(errorMsg)")
                self.error = errorMsg
                return
            }
            
            if let viewController = viewController {
                logger.info("GameKit auth UI needed")
                DispatchQueue.main.async {
                    self.matchmakerViewController = viewController as? GKMatchmakerViewController
                }
                return
            }
            
            if GKLocalPlayer.local.isAuthenticated {
                self.localPlayer = GKLocalPlayer.local
                self.isAuthenticated = true
                logger.info("GameKit authenticated: \(GKLocalPlayer.local.displayName)")
            }
        }
    }
    
    public func startMatchmaking(minPlayers: Int = 2, maxPlayers: Int = 4) {
        guard isAuthenticated else {
            let errorMsg = "Not authenticated with GameKit"
            logger.error("\(errorMsg)")
            error = errorMsg
            return
        }
        
        logger.info("Starting matchmaking: minPlayers=\(minPlayers), maxPlayers=\(maxPlayers)")
        
        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers
        
        let matchmakerViewController = GKMatchmakerViewController(matchRequest: request)
        matchmakerViewController?.matchmakerDelegate = self
        
        DispatchQueue.main.async {
            self.matchmakerViewController = matchmakerViewController
            logger.info("Presenting GKMatchmakerViewController")
        }
    }
    
    public func sendData(_ data: Data, to players: [GKPlayer]? = nil) throws {
        guard let match = match else {
            let errorMsg = "No active match"
            logger.error("\(errorMsg)")
            throw NSError(domain: "GameKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
        
        let recipients = players ?? match.players
        logger.debug("Sending data to \(recipients.count) players")
        try match.send(data, to: recipients, dataMode: .reliable)
    }
    
    public func disconnect() {
        logger.info("Disconnecting from match")
        match?.disconnect()
        match = nil
        matchStarted = false
        connectedPlayers = []
        matchmakerViewController = nil
    }
}

extension GameKitManager: GKMatchmakerViewControllerDelegate {
    public func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        logger.info("Matchmaker cancelled by user")
        DispatchQueue.main.async {
            self.matchmakerViewController = nil
        }
    }
    
    public func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        let errorMsg = "Matchmaker error: \(error.localizedDescription)"
        logger.error("\(errorMsg)")
        DispatchQueue.main.async {
            self.error = errorMsg
            self.matchmakerViewController = nil
        }
    }
    
    public func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        logger.info("Match found with \(match.players.count) players")
        DispatchQueue.main.async {
            self.match = match
            match.delegate = self
            self.connectedPlayers = match.players
            self.matchStarted = true
            self.matchmakerViewController = nil
        }
    }
}

extension GameKitManager: GKMatchDelegate {
    public func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        logger.debug("Received data from player: \(player.displayName)")
        DispatchQueue.main.async {
            self.receivedData = data
        }
    }
    
    public func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        logger.info("Player \(player.displayName) state changed: \(state.rawValue)")
        DispatchQueue.main.async {
            self.connectedPlayers = match.players
            
            if state == .disconnected {
                self.error = "Player disconnected: \(player.displayName)"
            }
        }
    }
    
    public func match(_ match: GKMatch, didFailWithError error: Error?) {
        let errorMsg = "Match error: \(error?.localizedDescription ?? "Unknown")"
        logger.error("\(errorMsg)")
        DispatchQueue.main.async {
            self.error = errorMsg
            self.matchStarted = false
        }
    }
}
