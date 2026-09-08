import Foundation

public final class AppDIContainer: @unchecked Sendable {
    public static let shared = AppDIContainer()

    public let projectRepository: ProjectRepositoryProtocol
    public let figmaSyncRepository: FigmaSyncRepositoryProtocol
    public let codeExportRepository: CodeExportRepositoryProtocol

    public let manageTokensUseCase: ManageTokensUseCaseProtocol
    public let managePresetsUseCase: ManagePresetsUseCaseProtocol
    public let exportCodeUseCase: ExportCodeUseCaseProtocol
    public let syncFigmaUseCase: SyncFigmaUseCaseProtocol

    private init() {
        let pRepo = ProjectRepositoryImpl()
        let fRepo = FigmaSyncRepositoryImpl()
        let cRepo = CodeExportRepositoryImpl()

        self.projectRepository = pRepo
        self.figmaSyncRepository = fRepo
        self.codeExportRepository = cRepo

        self.manageTokensUseCase = ManageTokensUseCase()
        self.managePresetsUseCase = ManagePresetsUseCase(repository: pRepo)
        self.exportCodeUseCase = ExportCodeUseCase(repository: cRepo)
        self.syncFigmaUseCase = SyncFigmaUseCase(repository: fRepo)
    }

    @MainActor
    public func makeProjectStore() -> ProjectStore {
        ProjectStore(
            manageTokensUseCase: manageTokensUseCase,
            managePresetsUseCase: managePresetsUseCase,
            exportCodeUseCase: exportCodeUseCase,
            syncFigmaUseCase: syncFigmaUseCase
        )
    }
}
