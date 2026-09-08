import Foundation

public protocol ManagePresetsUseCaseProtocol: AnyObject {
    func loadDefaultProject() -> DesignSystemProject
    func loadPreset(_ preset: PresetTemplate) -> DesignSystemProject
    func loadCustomPresets() -> [CustomPreset]
    func saveCustomPreset(name: String, project: DesignSystemProject) -> CustomPreset
    func deleteCustomPreset(id: UUID)
}

public final class ManagePresetsUseCase: ManagePresetsUseCaseProtocol {
    private let repository: ProjectRepositoryProtocol

    public init(repository: ProjectRepositoryProtocol) {
        self.repository = repository
    }

    public func loadDefaultProject() -> DesignSystemProject {
        repository.loadDefaultProject()
    }

    public func loadPreset(_ preset: PresetTemplate) -> DesignSystemProject {
        repository.loadPreset(preset)
    }

    public func loadCustomPresets() -> [CustomPreset] {
        repository.loadCustomPresets()
    }

    public func saveCustomPreset(name: String, project: DesignSystemProject) -> CustomPreset {
        repository.saveCustomPreset(name: name, project: project)
    }

    public func deleteCustomPreset(id: UUID) {
        repository.deleteCustomPreset(id: id)
    }
}
