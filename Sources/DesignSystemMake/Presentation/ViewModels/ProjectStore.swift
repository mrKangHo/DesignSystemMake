import Foundation
import SwiftUI
import Combine

@MainActor
public final class ProjectStore: ObservableObject {
    @Published public var project: DesignSystemProject
    @Published public var selectedTokenID: UUID?
    @Published public var searchQuery: String = ""
    @Published public var selectedGroupFilter: String? = nil
    @Published public var selectedTypeFilter: TokenType? = nil
    @Published public var activePreset: PresetTemplate? = .appleHIG
    @Published public var customPresets: [CustomPreset] = []
    @Published public var activeCustomPresetID: UUID? = nil

    private let manageTokensUseCase: ManageTokensUseCaseProtocol
    private let managePresetsUseCase: ManagePresetsUseCaseProtocol
    private let exportCodeUseCase: ExportCodeUseCaseProtocol
    private let syncFigmaUseCase: SyncFigmaUseCaseProtocol

    public init(
        manageTokensUseCase: ManageTokensUseCaseProtocol = AppDIContainer.shared.manageTokensUseCase,
        managePresetsUseCase: ManagePresetsUseCaseProtocol = AppDIContainer.shared.managePresetsUseCase,
        exportCodeUseCase: ExportCodeUseCaseProtocol = AppDIContainer.shared.exportCodeUseCase,
        syncFigmaUseCase: SyncFigmaUseCaseProtocol = AppDIContainer.shared.syncFigmaUseCase
    ) {
        self.manageTokensUseCase = manageTokensUseCase
        self.managePresetsUseCase = managePresetsUseCase
        self.exportCodeUseCase = exportCodeUseCase
        self.syncFigmaUseCase = syncFigmaUseCase

        let defaultProject = managePresetsUseCase.loadDefaultProject()
        self.project = defaultProject
        self.selectedTokenID = defaultProject.tokens.first?.id
        self.customPresets = managePresetsUseCase.loadCustomPresets()
    }

    public var filteredTokens: [DesignToken] {
        manageTokensUseCase.filterTokens(
            tokens: project.tokens,
            query: searchQuery,
            groupFilter: selectedGroupFilter,
            typeFilter: selectedTypeFilter
        )
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
        self.project = managePresetsUseCase.loadPreset(preset)
        self.selectedTokenID = self.project.tokens.first?.id
    }

    // MARK: - Custom Presets Management
    public func saveCurrentAsCustomPreset(name: String) {
        let preset = managePresetsUseCase.saveCustomPreset(name: name, project: self.project)
        self.customPresets.append(preset)
        self.activeCustomPresetID = preset.id
        self.activePreset = nil
        self.project = preset.project
    }

    public func loadCustomPreset(_ customPreset: CustomPreset) {
        self.activeCustomPresetID = customPreset.id
        self.activePreset = nil
        self.project = customPreset.project
        self.selectedTokenID = self.project.tokens.first?.id
    }

    public func deleteCustomPreset(id: UUID) {
        self.customPresets.removeAll(where: { $0.id == id })
        managePresetsUseCase.deleteCustomPreset(id: id)
        if self.activeCustomPresetID == id {
            self.activeCustomPresetID = nil
            loadPreset(.appleHIG)
        }
    }
}
