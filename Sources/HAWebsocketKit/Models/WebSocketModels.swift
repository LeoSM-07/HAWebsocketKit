import Foundation

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

public enum HAWebSocketError: Error, LocalizedError {
    case returnMessageDataInvalid, unableToDetermineIncomingMessageType

    public var errorDescription: String {
        switch self {
        case .returnMessageDataInvalid: return "Unable to parse the incoming data from the server"
        case .unableToDetermineIncomingMessageType: return "Unknown message type returned from the server"
        }
    }
}
