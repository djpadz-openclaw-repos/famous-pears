import Foundation
import MultipeerConnectivity
import os.log

private let logger = Logger(subsystem: "com.famous-peers.tvmultiplayer", category: "TVMultiplayerManager")

@MainActor
public class TVMultiplayerManager: NSObject, ObservableObject {
    @Published public var isHosting = false
    @Published public var connectedPlayers: [String] = []
    @Published public var error: String?
    @Published public var gameState: TVGameState = .waiting
    @Published public var receivedMessage: NetworkMessage?
    
    private let multipeerManager: MultipeerManager
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var hostName: String
    
    public enum TVGameState {
        case waiting
        case playersConnecting
        case readyToStart
        case gameActive
        case gameEnded
    }
    
    public init(hostName: String) {
        self.hostName = hostName
        self.multipeerManager = MultipeerManager(displayName: hostName, isHost: true)
        super.init()
        setupObservers()
        logger.info("TVMultiplayerManager initialized as host: \(hostName)")
    }
    
    private func setupObservers() {
        Task {
            for await connected in multipeerManager.$isConnected.values {
                DispatchQueue.main.async {
                    self.isHosting = connected
                    logger.info("Host connection status: \(connected)")
                }
            }
        }
        
        Task {
            for await peers in multipeerManager.$connectedPeers.values {
                DispatchQueue.main.async {
                    self.connectedPlayers = peers.map { $0.displayName }
                    logger.info("Connected players: \(self.connectedPlayers.count)")
                    self.updateGameState()
                }
            }
        }
        
        Task {
            for await data in multipeerManager.$receivedData.values {
                if let data = data {
                    self.handleReceivedData(data)
                }
            }
        }
        
        Task {
            for await error in multipeerManager.$error.values {
                if let error = error {
                    DispatchQueue.main.async {
                        self.error = error
                        logger.error("Multiplayer error: \(error)")
                    }
                }
            }
        }
    }
    
    private func updateGameState() {
        let playerCount = connectedPlayers.count
        
        switch gameState {
        case .waiting:
            if playerCount > 0 {
                gameState = .playersConnecting
                logger.info("Players connecting: \(playerCount)")
            }
        case .playersConnecting:
            if playerCount >= 2 {
                gameState = .readyToStart
                logger.info("Ready to start game with \(playerCount) players")
            }
        default:
            break
        }
    }
    
    private func handleReceivedData(_ data: Data) {
        do {
            let message = try decoder.decode(NetworkMessage.self, from: data)
            DispatchQueue.main.async {
                self.receivedMessage = message
                logger.debug("Received message: \(String(describing: message)))")
            }
        } catch {
            let errorMsg = "Failed to decode message: \(error.localizedDescription)"
            logger.error("\(errorMsg)")
            DispatchQueue.main.async {
                self.error = errorMsg
            }
        }
    }
    
    public func broadcastMessage(_ message: NetworkMessage) throws {
        let data = try encoder.encode(message)
        logger.debug("Broadcasting message to \(self.connectedPlayers.count) players")
        try multipeerManager.sendData(data)
    }
    
    public func sendMessage(_ message: NetworkMessage, to playerName: String) throws {
        let data = try encoder.encode(message)
        
        guard let targetPeer = multipeerManager.session?.connectedPeers.first(where: { $0.displayName == playerName }) else {
            let errorMsg = "Player not found: \(playerName)"
            logger.error("\(errorMsg)")
            throw NSError(domain: "TVMultiplayerManager", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
        
        logger.debug("Sending message to player: \(playerName)")
        try multipeerManager.sendData(data, to: [targetPeer])
    }
    
    public func startGame() {
        guard gameState == .readyToStart else {
            let errorMsg = "Game not ready to start. Current state: \(gameState)"
            logger.error("\(errorMsg)")
            error = errorMsg
            return
        }
        
        gameState = .gameActive
        logger.info("Game started with \(connectedPlayers.count) players")
    }
    
    public func endGame() {
        gameState = .gameEnded
        logger.info("Game ended")
    }
    
    public func resetGame() {
        gameState = .waiting
        logger.info("Game reset")
    }
    
    public func disconnect() {
        logger.info("Disconnecting from multiplayer session")
        multipeerManager.disconnect()
        isHosting = false
        connectedPlayers = []
        gameState = .waiting
    }
    
    // Access to underlying session for advanced operations
    public var session: MCSession? {
        multipeerManager.session
    }
}
