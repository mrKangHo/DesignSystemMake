import Foundation
import SwiftUI
import Combine

public enum PresetTemplate: String, CaseIterable, Identifiable {
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

public struct CustomPreset: Identifiable, Codable {
    public var id: UUID
    public var name: String
    public var project: DesignSystemProject
    
    public init(id: UUID = UUID(), name: String, project: DesignSystemProject) {
        self.id = id
        self.name = name
        self.project = project
    }
}

@MainActor
public class ProjectStore: ObservableObject {
    @Published public var project: DesignSystemProject
    @Published public var selectedTokenID: UUID?
    @Published public var searchQuery: String = ""
    @Published public var selectedGroupFilter: String? = nil
    @Published public var selectedTypeFilter: TokenType? = nil
    @Published public var activePreset: PresetTemplate? = .appleHIG
    @Published public var customPresets: [CustomPreset] = []
    @Published public var activeCustomPresetID: UUID? = nil
    
    public init() {
        self.project = ProjectStore.createAppleHIGPreset()
        self.selectedTokenID = self.project.tokens.first?.id
        loadCustomPresetsFromDisk()
    }
    
    public var filteredTokens: [DesignToken] {
        project.tokens.filter { token in
            if !searchQuery.isEmpty {
                let q = searchQuery.lowercased()
                let matchName = token.name.lowercased().contains(q)
                let matchDisplay = token.displayName.lowercased().contains(q)
                let matchDesc = token.description.lowercased().contains(q)
                guard matchName || matchDisplay || matchDesc else { return false }
            }
            
            if let group = selectedGroupFilter, token.groupName != group {
                return false
            }
            
            if let type = selectedTypeFilter, token.type != type {
                return false
            }
            
            return true
        }
    }
    
    public var selectedToken: DesignToken? {
        get {
            guard let id = selectedTokenID else { return nil }
            return project.tokens.first(where: { $0.id == id })
        }
        set {
            if let updated = newValue, let index = project.tokens.firstIndex(where: { $0.id == updated.id }) {
                project.tokens[index] = updated
                project.lastModified = Date()
            }
        }
    }
    
    // MARK: - Actions
    public func addToken(_ token: DesignToken) {
        project.tokens.append(token)
        project.lastModified = Date()
        selectedTokenID = token.id
    }
    
    public func deleteToken(id: UUID) {
        project.tokens.removeAll(where: { $0.id == id })
        project.lastModified = Date()
        if selectedTokenID == id {
            selectedTokenID = project.tokens.first?.id
        }
    }
    
    public func updateToken(_ token: DesignToken) {
        if let index = project.tokens.firstIndex(where: { $0.id == token.id }) {
            project.tokens[index] = token
            project.lastModified = Date()
        }
    }
    
    public func loadPreset(_ preset: PresetTemplate) {
        self.activePreset = preset
        self.activeCustomPresetID = nil
        switch preset {
        case .appleHIG:
            self.project = ProjectStore.createAppleHIGPreset()
        case .tailwind:
            self.project = ProjectStore.createTailwindPreset()
        case .material3:
            self.project = ProjectStore.createMaterial3Preset()
        case .antDesign:
            self.project = ProjectStore.createAntDesignPreset()
        }
        self.selectedTokenID = self.project.tokens.first?.id
    }
    
    // MARK: - Custom Presets Management
    public func saveCurrentAsCustomPreset(name: String) {
        var copyProject = self.project
        copyProject.name = name
        let preset = CustomPreset(name: name, project: copyProject)
        self.customPresets.append(preset)
        self.activeCustomPresetID = preset.id
        self.activePreset = nil
        self.project = copyProject
        saveCustomPresetsToDisk()
    }
    
    public func loadCustomPreset(_ customPreset: CustomPreset) {
        self.activeCustomPresetID = customPreset.id
        self.activePreset = nil
        self.project = customPreset.project
        self.selectedTokenID = self.project.tokens.first?.id
    }
    
    public func deleteCustomPreset(id: UUID) {
        self.customPresets.removeAll(where: { $0.id == id })
        if self.activeCustomPresetID == id {
            self.activeCustomPresetID = nil
            loadPreset(.appleHIG)
        }
        saveCustomPresetsToDisk()
    }
    
    // Disk Persistence
    private var presetsFileURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("DesignSystemMake", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("custom_presets.json")
    }
    
    private func saveCustomPresetsToDisk() {
        if let data = try? JSONEncoder().encode(customPresets) {
            try? data.write(to: presetsFileURL)
        }
    }
    
    private func loadCustomPresetsFromDisk() {
        if let data = try? Data(contentsOf: presetsFileURL),
           let presets = try? JSONDecoder().decode([CustomPreset].self, from: data) {
            self.customPresets = presets
        }
    }
    
    // MARK: - Preset 1: Apple HIG (Human Interface Guidelines)
    public static func createAppleHIGPreset() -> DesignSystemProject {
        let tokens: [DesignToken] = [
            DesignToken(
                name: "color.brand.primary",
                displayName: "System Blue",
                type: .color,
                description: "Standard Apple System Blue accent color for primary buttons, active links, and tint.",
                groupName: "System Accent",
                colorValue: ColorTokenValue(lightHex: "#007AFF", darkHex: "#0A84FF")
            ),
            DesignToken(
                name: "color.brand.secondary",
                displayName: "System Indigo",
                type: .color,
                description: "System Indigo for secondary controls, badges, and accent highlights.",
                groupName: "System Accent",
                colorValue: ColorTokenValue(lightHex: "#5856D6", darkHex: "#5E5CE6")
            ),
            DesignToken(
                name: "color.brand.purple",
                displayName: "System Purple",
                type: .color,
                description: "System Purple for creative actions and specialized categories.",
                groupName: "System Accent",
                colorValue: ColorTokenValue(lightHex: "#AF52DE", darkHex: "#BF5AF2")
            ),
            DesignToken(
                name: "color.neutral.background",
                displayName: "System Background",
                type: .color,
                description: "Primary canvas view background color for light and dark Aqua appearances.",
                groupName: "Neutral Surfaces",
                colorValue: ColorTokenValue(lightHex: "#FFFFFF", darkHex: "#000000")
            ),
            DesignToken(
                name: "color.neutral.groupedBackground",
                displayName: "Secondary Grouped Background",
                type: .color,
                description: "Grouped table and list row container background.",
                groupName: "Neutral Surfaces",
                colorValue: ColorTokenValue(lightHex: "#F2F2F7", darkHex: "#1C1C1E")
            ),
            DesignToken(
                name: "color.neutral.textPrimary",
                displayName: "Label Primary Text",
                type: .color,
                description: "High-contrast label text color for prominent content.",
                groupName: "Neutral Typography",
                colorValue: ColorTokenValue(lightHex: "#000000", darkHex: "#FFFFFF")
            ),
            DesignToken(
                name: "color.status.success",
                displayName: "System Green",
                type: .color,
                description: "System Green for positive state confirmation and positive metrics.",
                groupName: "System Status",
                colorValue: ColorTokenValue(lightHex: "#34C759", darkHex: "#30D158")
            ),
            DesignToken(
                name: "color.status.warning",
                displayName: "System Orange",
                type: .color,
                description: "System Orange for pending alerts, caution, and warning states.",
                groupName: "System Status",
                colorValue: ColorTokenValue(lightHex: "#FF9500", darkHex: "#FF9F0A")
            ),
            DesignToken(
                name: "color.status.danger",
                displayName: "System Red",
                type: .color,
                description: "System Red for destructive buttons, errors, and critical notifications.",
                groupName: "System Status",
                colorValue: ColorTokenValue(lightHex: "#FF3B30", darkHex: "#FF453A")
            ),
            DesignToken(
                name: "typography.heading.largeTitle",
                displayName: "Large Title (34pt)",
                type: .typography,
                description: "Prominent navigation bar titles and hero headers.",
                groupName: "Headings",
                typographyValue: TypographyTokenValue(fontFamily: "SF Pro Display", fontSize: 34, fontWeight: "Bold", lineHeight: 41, letterSpacing: 0.37)
            ),
            DesignToken(
                name: "typography.heading.title1",
                displayName: "Title 1 (28pt)",
                type: .typography,
                description: "Primary content section headers.",
                groupName: "Headings",
                typographyValue: TypographyTokenValue(fontFamily: "SF Pro Display", fontSize: 28, fontWeight: "Bold", lineHeight: 34, letterSpacing: 0.36)
            ),
            DesignToken(
                name: "typography.body.regular",
                displayName: "Body Regular (17pt)",
                type: .typography,
                description: "Standard body copy text size across iOS and macOS.",
                groupName: "Body Copy",
                typographyValue: TypographyTokenValue(fontFamily: "SF Pro Text", fontSize: 17, fontWeight: "Regular", lineHeight: 22, letterSpacing: -0.41)
            ),
            DesignToken(
                name: "typography.caption.subhead",
                displayName: "Subheadline (15pt)",
                type: .typography,
                description: "Secondary labels and card subheadings.",
                groupName: "Body Copy",
                typographyValue: TypographyTokenValue(fontFamily: "SF Pro Text", fontSize: 15, fontWeight: "Regular", lineHeight: 20, letterSpacing: -0.24)
            ),
            DesignToken(
                name: "spacing.xs",
                displayName: "Space 4px",
                type: .spacing,
                description: "Micro gap between inline elements.",
                groupName: "8pt Grid Scale",
                spacingValue: SpacingTokenValue(value: 4, unit: "px")
            ),
            DesignToken(
                name: "spacing.sm",
                displayName: "Space 8px",
                type: .spacing,
                description: "Standard element spacing inside buttons and list rows.",
                groupName: "8pt Grid Scale",
                spacingValue: SpacingTokenValue(value: 8, unit: "px")
            ),
            DesignToken(
                name: "spacing.md",
                displayName: "Space 16px",
                type: .spacing,
                description: "Default card internal padding and screen margin.",
                groupName: "8pt Grid Scale",
                spacingValue: SpacingTokenValue(value: 16, unit: "px")
            ),
            DesignToken(
                name: "spacing.lg",
                displayName: "Space 24px",
                type: .spacing,
                description: "Section gap and container padding.",
                groupName: "8pt Grid Scale",
                spacingValue: SpacingTokenValue(value: 24, unit: "px")
            ),
            DesignToken(
                name: "radius.control",
                displayName: "Control Radius (6px)",
                type: .radius,
                description: "Subtle rounded corner for buttons and text inputs.",
                groupName: "Corner Radii",
                radiusValue: RadiusTokenValue(value: 6)
            ),
            DesignToken(
                name: "radius.card",
                displayName: "Card Radius (12px)",
                type: .radius,
                description: "Continuous squircle corner radius for cards and modals.",
                groupName: "Corner Radii",
                radiusValue: RadiusTokenValue(value: 12)
            ),
            DesignToken(
                name: "radius.sheet",
                displayName: "Sheet Radius (22px)",
                type: .radius,
                description: "Bottom sheet and dialog modal corner radius.",
                groupName: "Corner Radii",
                radiusValue: RadiusTokenValue(value: 22)
            ),
            DesignToken(
                name: "shadow.modal",
                displayName: "macOS Window Shadow",
                type: .shadow,
                description: "Soft ambient drop shadow for floating macOS popovers and windows.",
                groupName: "Elevation",
                shadowValue: ShadowTokenValue(x: 0, y: 12, blur: 32, spread: 0, colorHex: "#000000", opacity: 0.18)
            )
        ]
        
        return DesignSystemProject(
            name: "Apple HIG System",
            version: "2.0.0",
            author: "Apple Human Interface Guidelines",
            description: "Official macOS and iOS system design token specifications",
            tokens: tokens
        )
    }
    
    // MARK: - Preset 2: Tailwind CSS & Radix UI
    public static func createTailwindPreset() -> DesignSystemProject {
        let tokens: [DesignToken] = [
            DesignToken(
                name: "color.brand.primary",
                displayName: "Indigo 600",
                type: .color,
                description: "Tailwind CSS default primary brand indigo accent.",
                groupName: "Tailwind Palette",
                colorValue: ColorTokenValue(lightHex: "#4F46E5", darkHex: "#6366F1")
            ),
            DesignToken(
                name: "color.brand.secondary",
                displayName: "Sky 500",
                type: .color,
                description: "Tailwind sky blue for highlights and active tab indicators.",
                groupName: "Tailwind Palette",
                colorValue: ColorTokenValue(lightHex: "#0EA5E9", darkHex: "#38BDF8")
            ),
            DesignToken(
                name: "color.neutral.background",
                displayName: "Slate 50 / 950",
                type: .color,
                description: "Slate neutral background for light and dark modes.",
                groupName: "Neutral Scales",
                colorValue: ColorTokenValue(lightHex: "#F8FAFC", darkHex: "#020617")
            ),
            DesignToken(
                name: "color.neutral.surface",
                displayName: "Slate 100 / 900",
                type: .color,
                description: "Elevated card surface.",
                groupName: "Neutral Scales",
                colorValue: ColorTokenValue(lightHex: "#FFFFFF", darkHex: "#0F172A")
            ),
            DesignToken(
                name: "color.status.success",
                displayName: "Emerald 500",
                type: .color,
                description: "Success green status color.",
                groupName: "Status Feedback",
                colorValue: ColorTokenValue(lightHex: "#10B981", darkHex: "#34D399")
            ),
            DesignToken(
                name: "color.status.warning",
                displayName: "Amber 500",
                type: .color,
                description: "Amber warning color.",
                groupName: "Status Feedback",
                colorValue: ColorTokenValue(lightHex: "#F59E0B", darkHex: "#FBBF24")
            ),
            DesignToken(
                name: "color.status.danger",
                displayName: "Rose 500",
                type: .color,
                description: "Rose danger error status.",
                groupName: "Status Feedback",
                colorValue: ColorTokenValue(lightHex: "#F43F5E", darkHex: "#FB7185")
            ),
            DesignToken(name: "spacing.1", displayName: "space-1 (4px)", type: .spacing, description: "Tailwind 1 unit", groupName: "Tailwind Spacing Scale", spacingValue: SpacingTokenValue(value: 4, unit: "px")),
            DesignToken(name: "spacing.2", displayName: "space-2 (8px)", type: .spacing, description: "Tailwind 2 unit", groupName: "Tailwind Spacing Scale", spacingValue: SpacingTokenValue(value: 8, unit: "px")),
            DesignToken(name: "spacing.4", displayName: "space-4 (16px)", type: .spacing, description: "Tailwind 4 unit", groupName: "Tailwind Spacing Scale", spacingValue: SpacingTokenValue(value: 16, unit: "px")),
            DesignToken(name: "spacing.6", displayName: "space-6 (24px)", type: .spacing, description: "Tailwind 6 unit", groupName: "Tailwind Spacing Scale", spacingValue: SpacingTokenValue(value: 24, unit: "px")),
            DesignToken(name: "radius.md", displayName: "rounded-md (6px)", type: .radius, description: "Medium radius", groupName: "Tailwind Radius", radiusValue: RadiusTokenValue(value: 6)),
            DesignToken(name: "radius.lg", displayName: "rounded-lg (8px)", type: .radius, description: "Large radius", groupName: "Tailwind Radius", radiusValue: RadiusTokenValue(value: 8)),
            DesignToken(name: "radius.xl", displayName: "rounded-xl (12px)", type: .radius, description: "Extra large radius", groupName: "Tailwind Radius", radiusValue: RadiusTokenValue(value: 12))
        ]
        
        return DesignSystemProject(
            name: "Tailwind UI & Radix System",
            version: "3.4.0",
            author: "Tailwind Labs & Radix UI",
            description: "Modern web standard design tokens matching Tailwind CSS utilities",
            tokens: tokens
        )
    }
    
    // MARK: - Preset 3: Google Material Design 3 (M3)
    public static func createMaterial3Preset() -> DesignSystemProject {
        let tokens: [DesignToken] = [
            DesignToken(
                name: "color.brand.primary",
                displayName: "M3 Primary Purple",
                type: .color,
                description: "Material 3 expressive primary brand token.",
                groupName: "Material Tonal Palette",
                colorValue: ColorTokenValue(lightHex: "#6750A4", darkHex: "#D0BCFF")
            ),
            DesignToken(
                name: "color.brand.secondary",
                displayName: "M3 Secondary",
                type: .color,
                description: "Secondary tonal accent for chips and navigation items.",
                groupName: "Material Tonal Palette",
                colorValue: ColorTokenValue(lightHex: "#625B71", darkHex: "#CCC2DC")
            ),
            DesignToken(
                name: "color.neutral.background",
                displayName: "M3 Surface Canvas",
                type: .color,
                description: "Material 3 background surface.",
                groupName: "Material Surfaces",
                colorValue: ColorTokenValue(lightHex: "#FEF7FF", darkHex: "#141218")
            ),
            DesignToken(
                name: "color.status.danger",
                displayName: "M3 Error",
                type: .color,
                description: "Material 3 error container tone.",
                groupName: "Material Status",
                colorValue: ColorTokenValue(lightHex: "#B3261E", darkHex: "#F2B8B5")
            ),
            DesignToken(name: "radius.small", displayName: "Corner Small (8px)", type: .radius, description: "M3 small corner radius", groupName: "M3 Shape Tokens", radiusValue: RadiusTokenValue(value: 8)),
            DesignToken(name: "radius.medium", displayName: "Corner Medium (12px)", type: .radius, description: "M3 medium card corner radius", groupName: "M3 Shape Tokens", radiusValue: RadiusTokenValue(value: 12)),
            DesignToken(name: "radius.large", displayName: "Corner Large (16px)", type: .radius, description: "M3 large modal corner radius", groupName: "M3 Shape Tokens", radiusValue: RadiusTokenValue(value: 16))
        ]
        
        return DesignSystemProject(
            name: "Material Design 3",
            version: "3.0.0",
            author: "Google Material Team",
            description: "Google Material You (M3) dynamic color and shape tokens",
            tokens: tokens
        )
    }
    
    // MARK: - Preset 4: Ant Design (B2B Enterprise)
    public static func createAntDesignPreset() -> DesignSystemProject {
        let tokens: [DesignToken] = [
            DesignToken(
                name: "color.brand.primary",
                displayName: "Daybreak Blue",
                type: .color,
                description: "Ant Design default enterprise primary blue.",
                groupName: "Ant Palette",
                colorValue: ColorTokenValue(lightHex: "#1677FF", darkHex: "#1668DC")
            ),
            DesignToken(
                name: "color.status.success",
                displayName: "Polar Green",
                type: .color,
                description: "Ant Design success green.",
                groupName: "Ant Status",
                colorValue: ColorTokenValue(lightHex: "#52C41A", darkHex: "#49AA19")
            ),
            DesignToken(
                name: "color.status.warning",
                displayName: "Sunset Gold",
                type: .color,
                description: "Ant Design warning amber.",
                groupName: "Ant Status",
                colorValue: ColorTokenValue(lightHex: "#FAAD14", darkHex: "#D89614")
            ),
            DesignToken(
                name: "color.status.danger",
                displayName: "Dust Red",
                type: .color,
                description: "Ant Design danger red.",
                groupName: "Ant Status",
                colorValue: ColorTokenValue(lightHex: "#FF4D4F", darkHex: "#DC4446")
            ),
            DesignToken(name: "radius.base", displayName: "Border Radius Base (6px)", type: .radius, description: "Ant Design standard corner radius", groupName: "Ant Shape", radiusValue: RadiusTokenValue(value: 6))
        ]
        
        return DesignSystemProject(
            name: "Ant Design System",
            version: "5.12.0",
            author: "Ant Group Enterprise",
            description: "Enterprise B2B design system tokens widely used in web portals",
            tokens: tokens
        )
    }
}
