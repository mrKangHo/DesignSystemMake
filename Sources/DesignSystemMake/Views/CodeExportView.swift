import SwiftUI
import AppKit

enum ExportCategoryGroup: String, CaseIterable, Identifiable {
    case apple = "Apple Ecosystem"
    case webAndMobile = "Web & Multi-Platform"
    case figma = "Figma Design Tools"
    case aiAndStandards = "AI Agents & Standards"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .apple: return "apple.logo"
        case .webAndMobile: return "globe"
        case .figma: return "square.on.square.squareshape.controlhandles"
        case .aiAndStandards: return "cpu"
        }
    }
    
    var targets: [ExportTarget] {
        switch self {
        case .apple:
            return [.swiftUI_iOS, .pureUIKit_iOS, .swiftUI_macOS, .pureAppKit_macOS]
        case .webAndMobile:
            return [.tailwind, .cssVariables, .jetpackCompose, .flutter]
        case .figma:
            return [.figmaTokensStudio, .figmaVariablesPlugin]
        case .aiAndStandards:
            return [.aiAgentMarkdown, .w3cJson]
        }
    }
}

public struct CodeExportView: View {
    @ObservedObject var store: ProjectStore
    @State private var selectedTarget: ExportTarget = .swiftUI_iOS
    @State private var isCopied: Bool = false
    @State private var showingFigmaSyncSheet: Bool = false
    
    private var generatedCode: String {
        CodeExporter.export(project: store.project, target: selectedTarget)
    }
    
    public var body: some View {
        HSplitView {
            // MARK: - 1. Structured Category Sidebar (Left Panel)
            VStack(alignment: .leading, spacing: 16) {
                Text("EXPORT TARGETS")
                    .font(.caption2.bold())
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        ForEach(ExportCategoryGroup.allCases) { group in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 6) {
                                    Image(systemName: group.iconName)
                                        .font(.caption.bold())
                                        .foregroundStyle(Color.accentColor)
                                    Text(group.rawValue.uppercased())
                                        .font(.system(.caption2, design: .monospaced).bold())
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 10)
                                
                                ForEach(group.targets) { target in
                                    TargetRowButton(
                                        target: target,
                                        isSelected: selectedTarget == target
                                    ) {
                                        withAnimation(.easeInOut(duration: 0.15)) {
                                            selectedTarget = target
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 16)
                }
            }
            .frame(width: 260)
            .background(Color(nsColor: .windowBackgroundColor))
            
            // MARK: - 2. Content & Viewer Panel (Right Panel)
            VStack(spacing: 0) {
                // Header Action Bar
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 8) {
                            Text(selectedTarget.rawValue)
                                .font(.title3.bold())
                            
                            Text(".\(selectedTarget.fileExtension)")
                                .font(.system(.caption, design: .monospaced).bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.12))
                                .foregroundStyle(Color.accentColor)
                                .clipShape(Capsule())
                        }
                        
                        let lineCount = generatedCode.components(separatedBy: .newlines).count
                        let charCount = generatedCode.count
                        Text("\(lineCount) lines • \(charCount) characters")
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // Direct Figma REST API Sync Shortcut Button
                    if selectedTarget == .figmaTokensStudio || selectedTarget == .figmaVariablesPlugin {
                        Button {
                            showingFigmaSyncSheet = true
                        } label: {
                            Label("Sync to Figma ⚡", systemImage: "paperplane.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)
                    }
                    
                    // Copy Code Button
                    Button {
                        copyToClipboard()
                    } label: {
                        Label(isCopied ? "Copied!" : "Copy Code", systemImage: isCopied ? "checkmark" : "doc.on.doc")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(isCopied ? .green : .accentColor)
                    
                    // File Export Button
                    Button {
                        saveFileToDisk()
                    } label: {
                        Label("Export File...", systemImage: "square.and.arrow.down")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Material.bar)
                
                Divider()
                
                // Guidance Banner Info Box
                TargetGuidanceBanner(target: selectedTarget) {
                    showingFigmaSyncSheet = true
                }
                
                // Code Viewer Box
                ScrollView([.horizontal, .vertical]) {
                    Text(generatedCode)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(Color.primary)
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(Color(nsColor: .textBackgroundColor))
            }
        }
        .sheet(isPresented: $showingFigmaSyncSheet) {
            FigmaSyncSheetView(store: store)
        }
    }
    
    private func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(generatedCode, forType: .string)
        
        isCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isCopied = false
        }
    }
    
    private func saveFileToDisk() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = []
        panel.nameFieldStringValue = "\(store.project.name.replacingOccurrences(of: " ", with: "_"))_tokens.\(selectedTarget.fileExtension)"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                try? generatedCode.write(to: url, atomically: true, encoding: .utf8)
            }
        }
    }
}

// MARK: - Target Navigation Row Button
struct TargetRowButton: View {
    let target: ExportTarget
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(target.rawValue)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
                    .lineLimit(1)
                
                Spacer()
                
                Text(".\(target.fileExtension)")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isSelected ? Color.accentColor.opacity(0.12) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Target Guidance Banner
struct TargetGuidanceBanner: View {
    let target: ExportTarget
    let onOpenFigmaSync: () -> Void
    
    var body: some View {
        switch target {
        case .aiAgentMarkdown:
            BannerBox(icon: "cpu", color: .green, title: "AI Agent Context Instruction (.md)") {
                Text("Save this file as **'DESIGN_SYSTEM.md'** in your repo root or copy into **Claude Code, Antigravity CLI, OpenAI Codex, or Cursor** to enforce design tokens.")
            }
        case .figmaTokensStudio:
            BannerBox(icon: "figma", color: .purple, title: "Figma Tokens Studio JSON") {
                HStack {
                    Text("Export as JSON or click Copy Code, then import into 'Tokens Studio for Figma' plugin. Or click 'Sync to Figma ⚡' above.")
                    Spacer()
                    Button("1-Click Direct Sync ⚡", action: onOpenFigmaSync)
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
            }
        case .figmaVariablesPlugin:
            BannerBox(icon: "sparkles", color: .blue, title: "Figma Native Variables JS Script") {
                Text("Copy Code → Open Figma Desktop → Press **Cmd+Option+I** (Figma Console) → Paste JS and hit Enter to auto-create native Figma Variables!")
            }
        case .swiftUI_iOS, .pureUIKit_iOS:
            BannerBox(icon: "iphone", color: .orange, title: "iOS UIKit & SwiftUI Native Tokens") {
                Text("Includes dynamic **UIColor dynamicProvider** for light/dark mode switching and **Font/CGFloat** extensions.")
            }
        case .swiftUI_macOS, .pureAppKit_macOS:
            BannerBox(icon: "macwindow", color: .indigo, title: "macOS AppKit & SwiftUI Native Tokens") {
                Text("Includes dynamic **NSColor dynamicProvider** for Aqua/DarkAqua appearance switching and **NSFont/CGFloat** extensions.")
            }
        default:
            EmptyView()
        }
    }
}

struct BannerBox<Content: View>: View {
    let icon: String
    let color: Color
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                content()
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(color.opacity(0.08))
        .border(color.opacity(0.18), width: 1)
    }
}
