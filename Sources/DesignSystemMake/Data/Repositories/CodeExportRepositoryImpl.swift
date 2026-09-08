import Foundation

public final class CodeExportRepositoryImpl: CodeExportRepositoryProtocol {
    public init() {}

    public func export(project: DesignSystemProject, target: ExportTarget) -> String {
        CodeExporter.export(project: project, target: target)
    }
}
