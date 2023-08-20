//
// File.swift
// 
//
// Created by LeoSM_07 on 8/20/23.
//

import Foundation

public struct HAContext: Codable, Hashable {
    let id: String
    let parentId: String?
    let userId: String?

    enum CodingKeys: String, CodingKey {
        case id
        case parentId = "parent_id"
        case userId = "user_id"
    }
}

public struct HAEntity: Decodable, Hashable {
    public static func == (lhs: HAEntity, rhs: HAEntity) -> Bool {
        lhs.entityId == rhs.entityId
    }

//    var attributes: [String: Any]
    var context: HAContext
    var entityId: String
    var lastChanged: String
    var lastUpdated: String
    var state: String

    enum CodingKeys: String, CodingKey {
        case attributes
        case context
        case entityId = "entity_id"
        case lastChanged = "last_changed"
        case lastUpdated = "last_updated"
        case state
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.attributes = try container.decode([String: Any].self, forKey: .attributes)
        self.context = try container.decode(HAContext.self, forKey: .context)
        self.entityId = try container.decode(String.self, forKey: .entityId)
        self.lastChanged = try container.decode(String.self, forKey: .lastChanged)
        self.lastUpdated = try container.decode(String.self, forKey: .lastUpdated)
        self.state = try container.decode(String.self, forKey: .state)
    }
}
