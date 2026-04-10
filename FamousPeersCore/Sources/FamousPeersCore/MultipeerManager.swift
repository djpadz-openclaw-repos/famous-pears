import MultipeerConnectivity
import Foundation

public protocol MultipeerManagerDelegate: AnyObject {
    func multipeerManager(_ manager: MultipeerManager, didReceiveMessage data: Data, from peer: MCPeerID)
    func multipeerManager(_ manager: MultipeerManager, peerConnected peer: MCPeerID)
    func multipeerManager(_ manager: MultipeerManager, peerDisconnected peer: MCPeerID)
}

public class MultipeerManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    public weak var delegate: MultipeerManagerDelegate?
    
    private let serviceType = "famous-peers"
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    
    public var connectedPeers: [MCPeerID] {
        return session?.connectedPeers ?? []
    }
    
    public override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
    }
    
    public func startHosting() {
        guard let session = session else { return }
        
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }
    
    public func startBrowsing() {
        guard let session = session else { return }
        
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }
    
    public func sendMessage(_ data: Data, to peers: [MCPeerID]? = nil) {
        guard let session = session else { return }
        
        let recipients = peers ?? session.connectedPeers
        
        do {
            try session.send(data, toPeers: recipients, with: .reliable)
        } catch {
            print("Error sending Multipeer message: \(error)")
        }
    }
    
    public func disconnect() {
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        session?.disconnect()
    }
    
    // MARK: - MCSessionDelegate
    
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            delegate?.multipeerManager(self, peerConnected: peerID)
        case .notConnected:
            delegate?.multipeerManager(self, peerDisconnected: peerID)
        case .connecting:
            break
        @unknown default:
            break
        }
    }
    
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        delegate?.multipeerManager(self, didReceiveMessage: data, from: peerID)
    }
    
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?) {}
    
    // MARK: - MCNearbyServiceAdvertiserDelegate
    
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
    
    // MARK: - MCNearbyServiceBrowserDelegate
    
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: session!, withContext: nil, timeout: 30)
    }
    
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
}
