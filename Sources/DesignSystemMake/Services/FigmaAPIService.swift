import Foundation
import SwiftUI

public struct FigmaSyncResult: Sendable {
    public let success: Bool
    public let message: String
    public let createdCount: Int
}

public class FigmaAPIService {
    
    /// Extract Figma file key from full URL (e.g., https://www.figma.com/design/aB1c2D3e4F5/My-Design-System -> aB1c2D3e4F5)
    public static func extractFileKey(from input: String) -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.contains("figma.com") {
            let components = trimmed.components(separatedBy: "/")
            if let index = components.firstIndex(where: { $0 == "file" || $0 == "design" || $0 == "board" }), index + 1 < components.count {
                return components[index + 1]
            }
        }
        return trimmed
    }
    
    /// Sync design system tokens directly to Figma File using Figma REST API v1
    public static func syncToFigma(
        project: DesignSystemProject,
        accessToken: String,
        fileKeyOrUrl: String,
        completion: @escaping @Sendable (FigmaSyncResult) -> Void
    ) {
        let fileKey = extractFileKey(from: fileKeyOrUrl)
        guard !fileKey.isEmpty else {
            completion(FigmaSyncResult(success: false, message: "Invalid Figma File Key or URL", createdCount: 0))
            return
        }
        
        guard !accessToken.isEmpty else {
            completion(FigmaSyncResult(success: false, message: "Personal Access Token is required", createdCount: 0))
            return
        }
        
        let endpoint = "https://api.figma.com/v1/files/\(fileKey)/variables"
        guard let url = URL(string: endpoint) else {
            completion(FigmaSyncResult(success: false, message: "Invalid API Endpoint", createdCount: 0))
            return
        }
        
        let tempCollectionId = "temp_coll_1"
        let tempModeId = "temp_mode_1"
        
        let variableCollections: [[String: Any]] = [
            [
                "action": "CREATE",
                "id": tempCollectionId,
                "name": project.name
            ]
        ]
        
        let variableModes: [[String: Any]] = [
            [
                "action": "CREATE",
                "id": tempModeId,
                "name": "Default",
                "variableCollectionId": tempCollectionId
            ]
        ]
        
        var variablesPayload: [[String: Any]] = []
        var variableModeValuesPayload: [[String: Any]] = []
        
        var count = 0
        for token in project.tokens {
            count += 1
            let tempVarId = "temp_var_\(count)"
            let varFigmaName = token.name.replacingOccurrences(of: ".", with: "/")
            
            switch token.type {
            case .color:
                if let val = token.colorValue, let rgb = ContrastCalculator.parseHex(val.lightHex) {
                    variablesPayload.append([
                        "action": "CREATE",
                        "id": tempVarId,
                        "name": varFigmaName,
                        "variableCollectionId": tempCollectionId,
                        "resolvedType": "COLOR"
                    ])
                    
                    variableModeValuesPayload.append([
                        "variableId": tempVarId,
                        "modeId": tempModeId,
                        "value": [
                            "r": rgb.r,
                            "g": rgb.g,
                            "b": rgb.b,
                            "a": rgb.a
                        ]
                    ])
                }
            case .spacing:
                if let val = token.spacingValue {
                    variablesPayload.append([
                        "action": "CREATE",
                        "id": tempVarId,
                        "name": varFigmaName,
                        "variableCollectionId": tempCollectionId,
                        "resolvedType": "FLOAT"
                    ])
                    
                    variableModeValuesPayload.append([
                        "variableId": tempVarId,
                        "modeId": tempModeId,
                        "value": val.value
                    ])
                }
            case .radius:
                if let val = token.radiusValue {
                    variablesPayload.append([
                        "action": "CREATE",
                        "id": tempVarId,
                        "name": varFigmaName,
                        "variableCollectionId": tempCollectionId,
                        "resolvedType": "FLOAT"
                    ])
                    
                    variableModeValuesPayload.append([
                        "variableId": tempVarId,
                        "modeId": tempModeId,
                        "value": val.value
                    ])
                }
            case .typography:
                if let val = token.typographyValue {
                    variablesPayload.append([
                        "action": "CREATE",
                        "id": tempVarId,
                        "name": "\(varFigmaName)/fontSize",
                        "variableCollectionId": tempCollectionId,
                        "resolvedType": "FLOAT"
                    ])
                    
                    variableModeValuesPayload.append([
                        "variableId": tempVarId,
                        "modeId": tempModeId,
                        "value": val.fontSize
                    ])
                }
            default:
                break
            }
        }
        
        let createdCount = variablesPayload.count
        
        let bodyPayload: [String: Any] = [
            "variableCollections": variableCollections,
            "variableModes": variableModes,
            "variables": variablesPayload,
            "variableModeValues": variableModeValuesPayload
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: bodyPayload, options: []) else {
            completion(FigmaSyncResult(success: false, message: "Failed to construct JSON payload", createdCount: 0))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(accessToken, forHTTPHeaderField: "X-Figma-Token")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(FigmaSyncResult(success: false, message: "Connection error: \(error.localizedDescription)", createdCount: 0))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(FigmaSyncResult(success: false, message: "Invalid HTTP Response from Figma", createdCount: 0))
                    return
                }
                
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    completion(FigmaSyncResult(
                        success: true,
                        message: "Successfully synced \(createdCount) variables directly to Figma file '\(fileKey)'!",
                        createdCount: createdCount
                    ))
                } else {
                    var errorDetail = "HTTP Status Code \(httpResponse.statusCode)"
                    if let data = data, let str = String(data: data, encoding: .utf8) {
                        errorDetail += ": \(str)"
                    }
                    completion(FigmaSyncResult(success: false, message: errorDetail, createdCount: 0))
                }
            }
        }
        task.resume()
    }
}
