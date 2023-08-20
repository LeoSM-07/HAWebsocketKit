import Foundation

public struct HAConfig: Codable {
    public let components: [String]
    public let configDir: String
    public let elevation: Int
    public let latitude: Double
    public let longitude: Double
    public let locationName: String
    public let timeZone: TimeZone
    public let unitSystem: HAUnitSystem
    public let version: String
    public let externalUrl: String?

    public struct HAUnitSystem: Codable {
        let length: String
        let mass: String
        let temperature: String
        let volume: String
    }

    enum CodingKeys: String, CodingKey {
        case components
        case configDir = "config_dir"
        case elevation
        case latitude
        case longitude
        case locationName = "location_name"
        case timeZone = "time_zone"
        case unitSystem = "unit_system"
        case version
        case externalUrl = "external_url"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.components = try container.decode([String].self, forKey: .components)
        self.configDir = try container.decode(String.self, forKey: .configDir)
        self.elevation = try container.decode(Int.self, forKey: .elevation)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
        self.locationName = try container.decode(String.self, forKey: .locationName)
        let timeZone = try container.decode(String.self, forKey: .timeZone)
        guard let newTimeZone = TimeZone(identifier: timeZone) else {
            throw DecodingError.typeMismatch(TimeZone.self, .init(codingPath: [CodingKeys.timeZone], debugDescription: "Unable to properly decode timezone"))
        }
        self.timeZone = newTimeZone
        self.unitSystem = try container.decode(HAConfig.HAUnitSystem.self, forKey: .unitSystem)
        self.version = try container.decode(String.self, forKey: .version)
        self.externalUrl = try container.decodeIfPresent(String.self, forKey: .externalUrl)
    }
}
