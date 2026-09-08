import Foundation

public protocol SyncFigmaUseCaseProtocol: Sendable {
    func execute(project: DesignSystemProject, accessToken: String, fileKeyOrUrl: String, completion: @escaping @Sendable (FigmaSyncResult) -> Void)
}

public final class SyncFigmaUseCase: SyncFigmaUseCaseProtocol {
    private let repository: FigmaSyncRepositoryProtocol

    public init(repository: FigmaSyncRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(project: DesignSystemProject, accessToken: String, fileKeyOrUrl: String, completion: @escaping @Sendable (FigmaSyncResult) -> Void) {
        repository.syncToFigma(project: project, accessToken: accessToken, fileKeyOrUrl: fileKeyOrUrl, completion: completion)
    }
}
