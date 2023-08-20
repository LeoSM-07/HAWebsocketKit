import Foundation
import Starscream
import OSLog

public class HAWebSocketConnection: WebSocketDelegate {
    private let logger = Logger(subsystem: "HAWebSocketKit", category: "HAWebSocketConnection")
    private let token: String
    private var socket: WebSocket
    private var messageCount: Int = 0
    private var lastMessageType: ReturnMessageType = .states

    public var isConnected = false
    public var status: HAWebSocketConnectionStatus = .disconnected

    public var states: Set<HAEntity>?
    public var config: HAConfig?

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
        case .connected(_):
            isConnected = true
            logger.info("HomeAssistant websocket is connected")
        case .disconnected(let reason, let code):
            isConnected = false
            status = .disconnected
            logger.info("HomeAssistant websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            do {
                try handleMessage(string)
            } catch {
                handleError(error)
            }
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

    private func handleMessage(_ message: String) throws {
        guard let messageData = message.data(using: .utf8) else {
            throw HAWebSocketError.returnMessageDataInvalid
        }

        guard let messageDictionary = try JSONSerialization.jsonObject(
            with: messageData,
            options: []
        ) as? [String: Any] else {
            throw HAWebSocketError.returnMessageDataInvalid
        }

        guard let messageType = messageDictionary["type"] as? String else {
            throw HAWebSocketError.unableToDetermineIncomingMessageType
        }

        switch messageType {
        case "auth_required":
            status = .requiresAuth
            authenticate()
        case "auth_ok":
            status = .fullyConnected
            logger.info("HA authentication complete, fully connected.")
            fetchData(type: .states)
        case "result":
            try handleResultMessage(messageDictionary)
        case "event":
            guard let event = messageDictionary["event"] as? String else {
                throw HAWebSocketError.returnMessageDataInvalid
            }
            try handleEventMessage(event)
        default: throw HAWebSocketError.unableToDetermineIncomingMessageType
        }
    }

    private func handleEventMessage(_ message: String) throws {

    }

    private func handleResultMessage(_ message: [String: Any]) throws {
        switch lastMessageType {
        case .states:
            let jsonResult = try JSONSerialization.data(withJSONObject: message["result"] as Any)
            let states = try JSONDecoder().decode(Set<HAEntity>.self, from: jsonResult)
            logger.log("Successfully retrieved server states")

            self.states = states
        case .config:
            let jsonResult = try JSONSerialization.data(withJSONObject: message["result"] as Any)
            let config = try JSONDecoder().decode(HAConfig.self, from: jsonResult)
            logger.log("Successfully retrieved server configuration")
            self.config = config
        default: print("Unknown type message: \(message)")
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
