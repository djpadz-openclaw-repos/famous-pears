import Foundation
import MultipeerConnectivity

@MainActor
public class MultipeerManager: NSObject, ObservableObject {
    @Published public var connectedPeers: [MCPeerID] = []
    @Published public var receivedData: Data?
    @Published public var error: String?
    @Published public var isConnected = false
    
    private let serviceType = "famous-pears"
    private var peerID: MCPeerID
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private let displayName: String
    private let isHost: Bool
    
    public init(displayName: String, isHost: Bool = false) {
        self.displayName = displayName
        self.isHost = isHost
        self.peerID = MCPeerID(displayName: displayName)
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
        
        if isHost {
            startAdvertising()
        } else {
            startBrowsing()
        }
    }
    
    private func startAdvertising() {
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: ["role": "host"], serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }
    
    private func startBrowsing() {
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }
    
    public func sendData(_ data: Data, to peers: [MCPeerID]? = nil) throws {
        guard let session = session else {
            throw NSError(domain: "MultipeerManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No active session"])
        }
        
        let recipients = peers ?? session.connectedPeers
        try session.send(data, toPeers: recipients, with: .reliable)
    }
    
    public func disconnect() {
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        session?.disconnect()
        isConnected = false
        connectedPeers = []
    }
}

extension MultipeerManager: MCSessionDelegate {
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                }
                self.isConnected = true
            case .connecting:
                break
            case .notConnected:
                self.connectedPeers.removeAll { $0 == peerID }
                if self.connectedPeers.isEmpty {
                    self.isConnected = false
                }
            @unknown default:
                break
            }
        }
    }
    
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.receivedData = data
        }
    }
    
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Not used for this app
    }
    
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Not used for this app
    }
    
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Not used for this app
    }
}

extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
            invitationHandler(true, self.session)
        }
    }
}

extension MultipeerManager: MCNearbyServiceBrowserDelegate {
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            browser.invitePeer(peerID, to: self.session!, withContext: nil, timeout: 30)
        }
    }
    
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        // Peer lost
    }
}
