import Foundation

public protocol ProjectRepositoryProtocol: AnyObject {
    func loadDefaultProject() -> DesignSystemProject
    func loadPreset(_ preset: PresetTemplate) -> DesignSystemProject
    func loadCustomPresets() -> [CustomPreset]
    func saveCustomPreset(name: String, project: DesignSystemProject) -> CustomPreset
    func deleteCustomPreset(id: UUID)
}
