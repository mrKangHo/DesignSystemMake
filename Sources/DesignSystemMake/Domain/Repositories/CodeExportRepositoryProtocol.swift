import Foundation

public protocol CodeExportRepositoryProtocol: Sendable {
    func export(project: DesignSystemProject, target: ExportTarget) -> String
}
