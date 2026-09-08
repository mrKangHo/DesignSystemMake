import Foundation

public final class ProjectRepositoryImpl: ProjectRepositoryProtocol {
    private let presetDataSource: PresetTemplatesDataSource
    private let storageDataSource: CustomPresetStorageDataSource
    private var customPresetsCache: [CustomPreset] = []

    public init(
        presetDataSource: PresetTemplatesDataSource = .shared,
        storageDataSource: CustomPresetStorageDataSource = .shared
    ) {
        self.presetDataSource = presetDataSource
        self.storageDataSource = storageDataSource
        self.customPresetsCache = storageDataSource.loadCustomPresets()
    }

    public func loadDefaultProject() -> DesignSystemProject {
        PresetTemplatesDataSource.createAppleHIGPreset()
    }

    public func loadPreset(_ preset: PresetTemplate) -> DesignSystemProject {
        switch preset {
        case .appleHIG:
            return PresetTemplatesDataSource.createAppleHIGPreset()
        case .tailwind:
            return PresetTemplatesDataSource.createTailwindPreset()
        case .material3:
            return PresetTemplatesDataSource.createMaterial3Preset()
        case .antDesign:
            return PresetTemplatesDataSource.createAntDesignPreset()
        }
    }

    public func loadCustomPresets() -> [CustomPreset] {
        customPresetsCache
    }

    public func saveCustomPreset(name: String, project: DesignSystemProject) -> CustomPreset {
        var copy = project
        copy.name = name
        let preset = CustomPreset(name: name, project: copy)
        customPresetsCache.append(preset)
        storageDataSource.saveCustomPresets(customPresetsCache)
        return preset
    }

    public func deleteCustomPreset(id: UUID) {
        customPresetsCache.removeAll(where: { $0.id == id })
        storageDataSource.saveCustomPresets(customPresetsCache)
    }
}
