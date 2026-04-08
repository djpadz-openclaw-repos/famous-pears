import Foundation
import GameKit

public class GameKitManager: NSObject, ObservableObject {
    @Published public var isAuthenticated = false
    @Published public var localPlayer: GKLocalPlayer?
    @Published public var connectedPlayers: [GKPlayer] = []
    @Published public var matchStarted = false
    
    public static let shared = GameKitManager()
    
    private var match: GKMatch?
    private var messageHandler: ((Data, GKPlayer) -> Void)?
    
    override private init() {
        super.init()
        authenticateLocalPlayer()
    }
    
    public func authenticateLocalPlayer() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            if let error = error {
                print("GameKit auth error: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self?.isAuthenticated = GKLocalPlayer.local.isAuthenticated
                self?.localPlayer = GKLocalPlayer.local
            }
        }
    }
    
    public func startMatchmaking(minPlayers: Int = 2, maxPlayers: Int = 4) {
        guard isAuthenticated else { return }
        
        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers
        
        GKMatchmakerViewController.showAndWaitForMatch(request) { [weak self] match, error in
            if let error = error {
                print("Matchmaking error: \(error.localizedDescription)")
                return
            }
            
            guard let match = match else { return }
            
            DispatchQueue.main.async {
                self?.match = match
                match.delegate = self
                self?.matchStarted = true
                self?.connectedPlayers = match.players
            }
        }
    }
    
    public func sendMessage(_ data: Data, to players: [GKPlayer]? = nil) {
        guard let match = match else { return }
        
        do {
            try match.send(data, to: players, dataMode: .reliable)
        } catch {
            print("Send error: \(error.localizedDescription)")
        }
    }
    
    public func onMessageReceived(_ handler: @escaping (Data, GKPlayer) -> Void) {
        self.messageHandler = handler
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
        messageHandler?(data, player)
    }
    
    public func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        DispatchQueue.main.async {
            self.connectedPlayers = match.players
        }
    }
    
    public func match(_ match: GKMatch, didFailWithError error: Error?) {
        print("Match error: \(error?.localizedDescription ?? "Unknown")")
        disconnect()
    }
}
