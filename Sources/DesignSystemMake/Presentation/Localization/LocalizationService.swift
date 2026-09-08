import Foundation
import SwiftUI

public enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case english = "en"
    case korean = "ko"
    case japanese = "ja"
    case chinese = "zh"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .english: return "English"
        case .korean: return "한국어"
        case .japanese: return "日本語"
        case .chinese: return "中文 (简体)"
        }
    }
    
    public var flagIcon: String {
        switch self {
        case .english: return "🇺🇸"
        case .korean: return "🇰🇷"
        case .japanese: return "🇯🇵"
        case .chinese: return "🇨🇳"
        }
    }
}

public class LocalizationManager: ObservableObject {
    public static let shared = LocalizationManager()
    
    @AppStorage("app_language") public var currentLanguage: AppLanguage = .korean {
        didSet {
            objectWillChange.send()
        }
    }
    
    public func localized(_ key: String) -> String {
        guard let dict = translations[key] else { return key }
        return dict[currentLanguage] ?? dict[.english] ?? key
    }
    
    private let translations: [String: [AppLanguage: String]] = [
        // Navigation & Titles
        "app_name": [
            .english: "DesignSystemMake",
            .korean: "디자인시스템 메이크",
            .japanese: "DesignSystemMake",
            .chinese: "DesignSystemMake 设计系统构建"
        ],
        "nav_tokens": [
            .english: "Design Tokens",
            .korean: "디자인 토큰",
            .japanese: "デザイン トークン",
            .chinese: "设计变量 Token"
        ],
        "nav_playground": [
            .english: "Component Playground",
            .korean: "컴포넌트 플레이그라운드",
            .japanese: "コンポーネント プレイグラウンド",
            .chinese: "组件演练场 Playground"
        ],
        "nav_exporter": [
            .english: "Code Exporter",
            .korean: "코드 내보내기",
            .japanese: "コード エクスポート",
            .chinese: "代码与文档导出 Exporter"
        ],
        
        // Actions & Buttons
        "add_token": [
            .english: "Add Token",
            .korean: "토큰 추가",
            .japanese: "トークン追加",
            .chinese: "添加 Token"
        ],
        "save_as_preset": [
            .english: "Save Current as Preset...",
            .korean: "현재 설정을 프리셋으로 저장...",
            .japanese: "現在の設定をプリセット保存...",
            .chinese: "将当前设置保存为预设..."
        ],
        "built_in_presets": [
            .english: "BUILT-IN PRESETS",
            .korean: "기본 제공 프리셋",
            .japanese: "組み込みプリセット",
            .chinese: "内置标准预设"
        ],
        "my_custom_presets": [
            .english: "MY CUSTOM PRESETS",
            .korean: "나만의 사용자 프리셋",
            .japanese: "カスタム プリセット",
            .chinese: "我的自定义预设"
        ],
        "search_placeholder": [
            .english: "Search tokens by name, group, or description...",
            .korean: "토큰 이름, 그룹 또는 설명으로 검색...",
            .japanese: "名前、グループ、説明でトークンを検索...",
            .chinese: "按名称、分组或描述搜索 Token..."
        ],
        "sync_to_figma": [
            .english: "Sync to Figma ⚡",
            .korean: "Figma로 직접 동기화 ⚡",
            .japanese: "Figmaへ同期 ⚡",
            .chinese: "一键同步到 Figma ⚡"
        ],
        "copy_code": [
            .english: "Copy Code",
            .korean: "코드 복사",
            .japanese: "コードをコピー",
            .chinese: "复制代码"
        ],
        "copied": [
            .english: "Copied!",
            .korean: "복사됨!",
            .japanese: "コピー完了!",
            .chinese: "已复制!"
        ],
        "export_file": [
            .english: "Export File...",
            .korean: "파일로 내보내기...",
            .japanese: "ファイル保存...",
            .chinese: "导出文件..."
        ],
        
        // Token Categories
        "cat_color": [
            .english: "Color Tokens",
            .korean: "색상 토큰",
            .japanese: "カラー トークン",
            .chinese: "颜色变量 Color"
        ],
        "cat_typography": [
            .english: "Typography Tokens",
            .korean: "타이포그래피 토큰",
            .japanese: "タイポグラフィ",
            .chinese: "字体排版 Typography"
        ],
        "cat_spacing": [
            .english: "Spacing Tokens",
            .korean: "스페이싱 토큰",
            .japanese: "スペーシング",
            .chinese: "间距变量 Spacing"
        ],
        "cat_radius": [
            .english: "Border Radius Tokens",
            .korean: "라운딩 토큰",
            .japanese: "角丸 Radius",
            .chinese: "圆角变量 Radius"
        ],
        "cat_shadow": [
            .english: "Shadow Tokens",
            .korean: "그림자 토큰",
            .japanese: "シャドウ Shadow",
            .chinese: "阴影变量 Shadow"
        ]
    ]
}

public extension String {
    var localized: String {
        LocalizationManager.shared.localized(self)
    }
}
