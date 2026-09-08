import Foundation

public protocol ExportCodeUseCaseProtocol: Sendable {
    func execute(project: DesignSystemProject, target: ExportTarget) -> String
}

public final class ExportCodeUseCase: ExportCodeUseCaseProtocol {
    private let repository: CodeExportRepositoryProtocol

    public init(repository: CodeExportRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(project: DesignSystemProject, target: ExportTarget) -> String {
        repository.export(project: project, target: target)
    }
}
