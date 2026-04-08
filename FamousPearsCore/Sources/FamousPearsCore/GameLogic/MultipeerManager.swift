import Foundation
import MultipeerConnectivity

public class MultipeerManager: NSObject, ObservableObject {
    @Published public var isConnected = false
    @Published public var connectedPeers: [MCPeerID] = []
    @Published public var receivedData: Data?
    
    public static let shared = MultipeerManager()
    
    private let serviceType = "famous-pears"
    private var peerID: MCPeerID
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private var messageHandler: ((Data, MCPeerID) -> Void)?
    
    override private init() {
        let deviceName = UIDevice.current.name
        self.peerID = MCPeerID(displayName: deviceName)
        super.init()
    }
    
    public func startAsHost() {
        let session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        self.session = session
        
        let advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        self.advertiser = advertiser
    }
    
    public func startAsClient() {
        let session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        self.session = session
        
        let browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser.delegate = self
        browser.startBrowsingForPeers()
        self.browser = browser
    }
    
    public func sendMessage(_ data: Data, to peers: [MCPeerID]? = nil) {
        guard let session = session else { return }
        
        let recipients = peers ?? session.connectedPeers
        do {
            try session.send(data, toPeers: recipients, with: .reliable)
        } catch {
            print("Send error: \(error.localizedDescription)")
        }
    }
    
    public func onMessageReceived(_ handler: @escaping (Data, MCPeerID) -> Void) {
        self.messageHandler = handler
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
            self.connectedPeers = session.connectedPeers
            self.isConnected = !session.connectedPeers.isEmpty
        }
    }
    
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.receivedData = data
            self.messageHandler?(data, peerID)
        }
    }
    
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?) {}
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
        guard let session = session else { return }
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
}
