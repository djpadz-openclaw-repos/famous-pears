import Foundation

@MainActor
public class NetworkCoordinator: NSObject, ObservableObject {
    @Published public var isConnected = false
    @Published public var connectedPlayerCount = 0
    @Published public var error: String?
    @Published public var receivedMessage: NetworkMessage?
    
    private var gameKitManager: GameKitManager?
    private var multipeerManager: MultipeerManager?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let mode: NetworkMode
    private let displayName: String
    
    public enum NetworkMode {
        case gameKit  // iOS-to-iOS via GameKit
        case multipeer(isHost: Bool)  // tvOS ↔ iOS via MultipeerConnectivity
    }
    
    public init(displayName: String, mode: NetworkMode) {
        self.displayName = displayName
        self.mode = mode
        super.init()
        setupManagers()
    }
    
    private func setupManagers() {
        switch mode {
        case .gameKit:
            gameKitManager = GameKitManager()
            observeGameKit()
        case .multipeer(let isHost):
            multipeerManager = MultipeerManager(displayName: displayName, isHost: isHost)
            observeMultipeer()
        }
    }
    
    private func observeGameKit() {
        guard let manager = gameKitManager else { return }
        
        Task {
            for await _ in manager.$isAuthenticated.values {
                updateConnectionStatus()
            }
        }
        
        Task {
            for await players in manager.$connectedPlayers.values {
                DispatchQueue.main.async {
                    self.connectedPlayerCount = players.count
                }
            }
        }
        
        Task {
            for await data in manager.$receivedData.values {
                if let data = data {
                    handleReceivedData(data)
                }
            }
        }
        
        Task {
            for await error in manager.$error.values {
                if let error = error {
                    DispatchQueue.main.async {
                        self.error = error
                    }
                }
            }
        }
    }
    
    private func observeMultipeer() {
        guard let manager = multipeerManager else { return }
        
        Task {
            for await connected in manager.$isConnected.values {
                DispatchQueue.main.async {
                    self.isConnected = connected
                }
            }
        }
        
        Task {
            for await peers in manager.$connectedPeers.values {
                DispatchQueue.main.async {
                    self.connectedPlayerCount = peers.count
                }
            }
        }
        
        Task {
            for await data in manager.$receivedData.values {
                if let data = data {
                    handleReceivedData(data)
                }
            }
        }
        
        Task {
            for await error in manager.$error.values {
                if let error = error {
                    DispatchQueue.main.async {
                        self.error = error
                    }
                }
            }
        }
    }
    
    private func updateConnectionStatus() {
        if let manager = gameKitManager {
            DispatchQueue.main.async {
                self.isConnected = manager.isAuthenticated && manager.matchStarted
            }
        }
    }
    
    private func handleReceivedData(_ data: Data) {
        do {
            let message = try decoder.decode(NetworkMessage.self, from: data)
            DispatchQueue.main.async {
                self.receivedMessage = message
            }
        } catch {
            DispatchQueue.main.async {
                self.error = "Failed to decode message: \(error.localizedDescription)"
            }
        }
    }
    
    public func sendMessage(_ message: NetworkMessage) throws {
        let data = try encoder.encode(message)
        
        switch mode {
        case .gameKit:
            try gameKitManager?.sendData(data)
        case .multipeer:
            try multipeerManager?.sendData(data)
        }
    }
    
    public func startMatchmaking(minPlayers: Int = 2, maxPlayers: Int = 4) {
        guard case .gameKit = mode else {
            error = "Matchmaking only available in GameKit mode"
            return
        }
        gameKitManager?.startMatchmaking(minPlayers: minPlayers, maxPlayers: maxPlayers)
    }
    
    public func disconnect() {
        gameKitManager?.disconnect()
        multipeerManager?.disconnect()
        isConnected = false
        connectedPlayerCount = 0
    }
}
