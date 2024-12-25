//
//  MultipeerConnectivityManager.swift
//  MultipieerApp
//
//  Created by Вячеслав Вовк on 25.12.2024.
//

import MultipeerConnectivity


class MultipeerManager: NSObject, ObservableObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {

    let serviceType = "mp-chat"
    var peerID: MCPeerID!
    var session: MCSession!
    var advertiser: MCNearbyServiceAdvertiser!
    var browser: MCNearbyServiceBrowser!
    
    @Published var messages: [String] = []

    override init() {
        super.init()

        peerID = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self

        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()

        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser.delegate = self
        browser.startBrowsingForPeers()
    }

    func sendMessage(_ message: String) {
        guard !session.connectedPeers.isEmpty, let data = message.data(using: .utf8) else { return }
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            DispatchQueue.main.async {
                self.messages.append("You: \(message)")
            }
        } catch {
            print("Error sending message: $$error.localizedDescription)")
        }
    }

    // MCSessionDelegate methods
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {}

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let message = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                self.messages.append("\(peerID.displayName): \(message)")
            }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
}
