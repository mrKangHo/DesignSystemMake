import Foundation
import SwiftUI

/// Supported token types in the design system
public enum TokenType: String, Codable, CaseIterable, Identifiable {
    case color = "Color"
    case typography = "Typography"
    case spacing = "Spacing"
    case radius = "Border Radius"
    case shadow = "Shadow"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .color: return "paintpalette.fill"
        case .typography: return "textformat"
        case .spacing: return "ruler.fill"
        case .radius: return "square.dashed"
        case .shadow: return "shadow"
        }
    }
}

/// Color value representation (Light & Dark variant)
public struct ColorTokenValue: Codable, Hashable {
    public var lightHex: String
    public var darkHex: String?
    public var opacity: Double
    
    public init(lightHex: String, darkHex: String? = nil, opacity: Double = 1.0) {
        self.lightHex = lightHex
        self.darkHex = darkHex
        self.opacity = opacity
    }
    
    public var effectiveDarkHex: String {
        darkHex ?? lightHex
    }
}

/// Typography value representation
public struct TypographyTokenValue: Codable, Hashable {
    public var fontFamily: String
    public var fontSize: Double // pt/px
    public var fontWeight: String // Regular, Medium, SemiBold, Bold
    public var lineHeight: Double // multiplier or px
    public var letterSpacing: Double // em/px
    
    public init(fontFamily: String = "SF Pro", fontSize: Double = 16, fontWeight: String = "Regular", lineHeight: Double = 24, letterSpacing: Double = 0) {
        self.fontFamily = fontFamily
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.lineHeight = lineHeight
        self.letterSpacing = letterSpacing
    }
}

/// Spacing value representation
public struct SpacingTokenValue: Codable, Hashable {
    public var value: Double // in px/rem
    public var unit: String // "px", "rem"
    
    public init(value: Double = 16, unit: String = "px") {
        self.value = value
        self.unit = unit
    }
}

/// Radius value representation
public struct RadiusTokenValue: Codable, Hashable {
    public var value: Double // in px
    
    public init(value: Double = 8) {
        self.value = value
    }
}

/// Shadow value representation
public struct ShadowTokenValue: Codable, Hashable {
    public var x: Double
    public var y: Double
    public var blur: Double
    public var spread: Double
    public var colorHex: String
    public var opacity: Double
    
    public init(x: Double = 0, y: Double = 4, blur: Double = 12, spread: Double = 0, colorHex: String = "#000000", opacity: Double = 0.15) {
        self.x = x
        self.y = y
        self.blur = blur
        self.spread = spread
        self.colorHex = colorHex
        self.opacity = opacity
    }
}

/// Main Design Token entity
public struct DesignToken: Identifiable, Codable, Hashable {
    public var id: UUID
    public var name: String // e.g. "color.brand.primary" or "brand-primary"
    public var displayName: String // e.g. "Brand Primary"
    public var type: TokenType
    public var description: String
    public var groupName: String
    
    // Value Payloads
    public var colorValue: ColorTokenValue?
    public var typographyValue: TypographyTokenValue?
    public var spacingValue: SpacingTokenValue?
    public var radiusValue: RadiusTokenValue?
    public var shadowValue: ShadowTokenValue?
    
    public init(
        id: UUID = UUID(),
        name: String,
        displayName: String,
        type: TokenType,
        description: String = "",
        groupName: String = "General",
        colorValue: ColorTokenValue? = nil,
        typographyValue: TypographyTokenValue? = nil,
        spacingValue: SpacingTokenValue? = nil,
        radiusValue: RadiusTokenValue? = nil,
        shadowValue: ShadowTokenValue? = nil
    ) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.type = type
        self.description = description
        self.groupName = groupName
        self.colorValue = colorValue
        self.typographyValue = typographyValue
        self.spacingValue = spacingValue
        self.radiusValue = radiusValue
        self.shadowValue = shadowValue
    }
}
