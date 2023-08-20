import Foundation
import Starscream
import OSLog

enum ReturnMessageType {
    case states, config, services, panels
}

public enum FetchDataType: String {
    case states = "get_states"
    case config = "get_config"
    case services = "get_services"
    case panels = "get_panels"

    var dataType: ReturnMessageType {
        switch self {
        case .states:
            return .states
        case .config:
            return .config
        case .services:
            return .services
        case .panels:
            return .panels
        }
    }
}

public enum HAWebSocketConnectionStatus {
    case disconnected
    case requiresAuth
    case fullyConnected
}

public class HAWebSocketConnection: WebSocketDelegate {
    private let logger = Logger(subsystem: "HAWebSocketKit", category: "HAWebSocketConnection")
    private let token: String
    private var socket: WebSocket
    private var messageCount: Int = 0
    private var lastMessageType: ReturnMessageType = .states

    public var isConnected = false
    public var status: HAWebSocketConnectionStatus = .disconnected

    public init(url serverUrl: URL, token serverToken: String) {
        self.token = serverToken

        let request = URLRequest(url: serverUrl)
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.respondToPingWithPong = true
    }

    public func connect() {
        socket.connect()
    }

    public func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            isConnected = true
            logger.info("HomeAssistant websocket is connected")
        case .disconnected(let reason, let code):
            isConnected = false
            status = .disconnected
            logger.info("HomeAssistant websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            handleMessage(string)
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
            status = .disconnected
        case .error(let error):
            isConnected = false
            status = .disconnected
            handleError(error)
        case .peerClosed:
            break
        }
    }

    private func handleMessage(_ message: String) {
        // Check to see if auth is required
        if message.contains("\"auth_required\"") {
            status = .requiresAuth
            do {
                try authenticate()
            } catch {
                handleError(error)
            }
        }
        // Check to see if auth was accepted
        else if message.contains("\"auth_ok\"") {
            status = .fullyConnected
            logger.info("HA authentication complete, fully connected.")
            fetchData(type: .config)
        } else {
            switch lastMessageType {
            case .states:
                print("States: \(message)")
            case .config:
                print("Config: \(message)")
            default: print("Unknown type message: \(message)")
            }
        }


    }

    public func fetchData(type: FetchDataType) {
        let message: [String: Codable] = ["id": messageCount, "type": type.rawValue]
        lastMessageType = type.dataType
        sendMessage(dictionary: message)
    }

    private func authenticate() {
        let message: [String: Codable] = ["type": "auth", "access_token": token]
        sendMessage(dictionary: message)
    }

    private func sendMessage(data message: Data) {
        socket.write(string: String(data: message, encoding: .utf8)!)
        messageCount += 1
    }

    private func sendMessage(dictionary message: [String: Codable]) {
        do {
            let json = try JSONSerialization.data(withJSONObject: message, options: .sortedKeys)
            sendMessage(data: json)
        } catch {
            handleError(error)
        }
    }

    private func handleError(_ error: Error?) {
        if let e = error as? WSError {
            logger.critical("HA websocket encountered an error: \(e.message)")
        } else if let e = error {
            logger.critical("HA websocket encountered an error: \(e.localizedDescription)")
        } else {
            logger.critical("HA websocket encountered an unknown error")
        }
    }

}
