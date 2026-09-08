import Foundation

public final class CustomPresetStorageDataSource: @unchecked Sendable {
    public static let shared = CustomPresetStorageDataSource()
    public init() {}

    private var presetsFileURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("DesignSystemMake", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("custom_presets.json")
    }

    public func loadCustomPresets() -> [CustomPreset] {
        guard let data = try? Data(contentsOf: presetsFileURL),
              let presets = try? JSONDecoder().decode([CustomPreset].self, from: data) else {
            return []
        }
        return presets
    }

    public func saveCustomPresets(_ presets: [CustomPreset]) {
        if let data = try? JSONEncoder().encode(presets) {
            try? data.write(to: presetsFileURL)
        }
    }
}
