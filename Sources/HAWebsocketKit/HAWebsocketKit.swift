import Foundation
import Starscream
import OSLog

public class HAWebSocketConnection: WebSocketDelegate {
    let logger = Logger(subsystem: "HAWebSocketKit", category: "HAWebSocketConnection")

    var socket: WebSocket
    var isConnected = false

    public init(url serverUrl: URL) {
        let request = URLRequest(url: serverUrl)

        socket = WebSocket(request: request)
        socket.delegate = self
    }

    public func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            handleError(error)
        case .peerClosed:
            break
        }
    }

    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            print("websocket encountered an error: \(e.message)")
            logger.critical("HA websocket encountered an error: \(e.message)")
        } else if let e = error {
            logger.critical("HA websocket encountered an error: \(e.localizedDescription)")
        } else {
            print("websocket encountered an error")
        }
    }

}
