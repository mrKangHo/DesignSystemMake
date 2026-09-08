import Foundation

public protocol ManageTokensUseCaseProtocol: Sendable {
    func filterTokens(tokens: [DesignToken], query: String, groupFilter: String?, typeFilter: TokenType?) -> [DesignToken]
}

public final class ManageTokensUseCase: ManageTokensUseCaseProtocol {
    public init() {}

    public func filterTokens(tokens: [DesignToken], query: String, groupFilter: String?, typeFilter: TokenType?) -> [DesignToken] {
        tokens.filter { token in
            if !query.isEmpty {
                let q = query.lowercased()
                let matchName = token.name.lowercased().contains(q)
                let matchDisplay = token.displayName.lowercased().contains(q)
                let matchDesc = token.description.lowercased().contains(q)
                guard matchName || matchDisplay || matchDesc else { return false }
            }
            if let group = groupFilter, token.groupName != group {
                return false
            }
            if let type = typeFilter, token.type != type {
                return false
            }
            return true
        }
    }
}
