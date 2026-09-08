import Foundation

public enum PresetTemplate: String, CaseIterable, Identifiable, Sendable {
    case appleHIG = "Apple HIG (iOS/macOS)"
    case tailwind = "Tailwind CSS & Radix"
    case material3 = "Google Material Design 3"
    case antDesign = "Ant Design (Enterprise B2B)"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .appleHIG: return "apple.logo"
        case .tailwind: return "wind"
        case .material3: return "paintpalette.fill"
        case .antDesign: return "building.2.fill"
        }
    }
}

public struct CustomPreset: Identifiable, Codable, Sendable {
    public var id: UUID
    public var name: String
    public var project: DesignSystemProject

    public init(id: UUID = UUID(), name: String, project: DesignSystemProject) {
        self.id = id
        self.name = name
        self.project = project
    }
}
