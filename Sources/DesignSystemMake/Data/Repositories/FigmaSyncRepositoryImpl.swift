import Foundation

public final class FigmaSyncRepositoryImpl: FigmaSyncRepositoryProtocol {
    public init() {}

    public func syncToFigma(project: DesignSystemProject, accessToken: String, fileKeyOrUrl: String, completion: @escaping @Sendable (FigmaSyncResult) -> Void) {
        FigmaAPIService.syncToFigma(project: project, accessToken: accessToken, fileKeyOrUrl: fileKeyOrUrl, completion: completion)
    }
}
