//
// File.swift
// 
//
// Created by LeoSM_07 on 8/27/23.
//

import Foundation
import SwiftUI

public enum HAEntityDomain: String, Identifiable, CaseIterable {
    public var id: String { self.rawValue }

    case person = "person"
    case binarySensor = "binary_sensor"
    case sensor = "sensor"
    case scene = "scene"
    case group = "group"
    case sun = "sun"
    case timer = "timer"
    case counter = "counter"
    case zone = "zone"
    case inputDateTime = "input_datetime"
    case inputSelect = "input_select"
    case inputNumber = "input_number"
    case inputBoolean = "input_boolean"
    case light = "light"
    case script = "script"
    case `switch` = "switch"
    case weather = "weather"
    case camera = "camera"
    case mediaPlayer = "media_player"
    case remote = "remote"
    case automation = "automation"
    case deviceTracker = "device_tracker"
    case calendar = "calendar"
    case button = "button"
    case update = "update"
    case waterHeater = "water_heater"
    case number = "number"
    case unknown = "unknown"

    public init(entityId: String) {
        self = HAEntityDomain(rawValue: String(entityId.split(separator: ".").first ?? "unknown")) ?? .unknown
    }

    public var name: String {
        switch self {
        case .person: return "Person"
        case .binarySensor: return "Binary Sensor"
        case .sensor: return "Sensor"
        case .scene: return "Scene"
        case .group: return "Group"
        case .sun: return "Sun"
        case .timer: return "Timer"
        case .counter: return "Counter"
        case .zone: return "Zone"
        case .inputDateTime: return "Input Date/Time"
        case .inputSelect: return "Input Select"
        case .inputNumber: return "Input Number"
        case .inputBoolean: return "Input Boolean"
        case .light: return "Light"
        case .script: return "Script"
        case .switch: return "Switch"
        case .weather: return "Weather"
        case .camera: return "Camera"
        case .mediaPlayer: return "Media Player"
        case .remote: return "Remote"
        case .automation: return "Automation"
        case .deviceTracker: return "Device Tracker"
        case .calendar: return "Calendar"
        case .button: return "Button"
        case .update: return "Update"
        case .waterHeater: return "Water Heater"
        case .number: return "Number"
        case .unknown: return "Unknown"
        }
    }

    public var color: Color {
        switch self {
        default: return .accentColor
        }
    }

    public var systemIcon: String {
        switch self {
        case .person: return "person.fill"
        case .binarySensor: return "sensor.fill"
        case .sensor: return "chart.bar.xaxis"
        case .scene: return "rectangle.3.group.fill"
        case .group: return "square.on.square.squareshape.controlhandles"
        case .sun: return "sun.and.horizon.fill"
        case .timer: return "timer"
        case .counter: return "square.stack.fill"
        case .zone: return "house.circle"
        case .inputDateTime: return "calendar.badge.clock"
        case .inputSelect: return "filemenu.and.selection"
        case .inputNumber: return "number.circle.fill"
        case .inputBoolean: return "switch.2"
        case .light: return "lightbulb.max.fill"
        case .script: return "applescript.fill"
        case .switch: return "lightswitch.on"
        case .weather: return "cloud.drizzle.fill"
        case .camera: return "web.camera.fill"
        case .mediaPlayer: return "rectangle.inset.filled.and.person.filled"
        case .remote: return "av.remote.fill"
        case .automation: return "alarm.fill"
        case .deviceTracker: return "antenna.radiowaves.left.and.right"
        case .calendar: return "calendar"
        case .button: return "button.programmable"
        case .update: return "arrow.triangle.2.circlepath"
        case .waterHeater: return "pipe.and.drop.fill"
        case .number: return "number"
        case .unknown: return "questionmark"
        }
    }
}

