import Foundation

public protocol FigmaSyncRepositoryProtocol: Sendable {
    func syncToFigma(project: DesignSystemProject, accessToken: String, fileKeyOrUrl: String, completion: @escaping @Sendable (FigmaSyncResult) -> Void)
}
