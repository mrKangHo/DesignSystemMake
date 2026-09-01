import Foundation

public struct DesignSystemProject: Identifiable, Codable {
    public var id: UUID
    public var name: String
    public var version: String
    public var author: String
    public var description: String
    public var tokens: [DesignToken]
    public var lastModified: Date
    
    public init(
        id: UUID = UUID(),
        name: String = "My Design System",
        version: String = "1.0.0",
        author: String = "Design Team",
        description: String = "Production-grade design tokens for iOS, Web, and Android",
        tokens: [DesignToken] = [],
        lastModified: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.version = version
        self.author = author
        self.description = description
        self.tokens = tokens
        self.lastModified = lastModified
    }
    
    public var tokenGroups: [String] {
        Array(Set(tokens.map { $0.groupName })).sorted()
    }
}
