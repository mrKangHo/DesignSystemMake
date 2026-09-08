import SwiftUI

public enum NavigationSection: String, CaseIterable, Identifiable {
    case tokens = "Tokens"
    case playground = "Playground"
    case exporter = "Code Exporter"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .tokens: return "slider.horizontal.3"
        case .playground: return "play.square.stack.fill"
        case .exporter: return "terminal.fill"
        }
    }
}

public struct SidebarView: View {
    @ObservedObject var store: ProjectStore
    @Binding var selectedSection: NavigationSection
    var onAddToken: (TokenType?) -> Void
    
    @State private var showingSavePresetSheet: Bool = false
    
    private var appIconImage: NSImage? {
        if let bundleUrl = Bundle.module.url(forResource: "AppIcon", withExtension: "png"),
           let img = NSImage(contentsOf: bundleUrl) {
            return img
        }
        let directPath = "/Users/lee/Documents/DesignSystemMake/Sources/DesignSystemMake/Resources/AppIcon.png"
        return NSImage(contentsOfFile: directPath)
    }
    
    public var body: some View {
        List {
            // MARK: - Project Header
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 10) {
                        if let nsImg = appIconImage {
                            Image(nsImage: nsImg)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 36, height: 36)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1.5)
                        } else {
                            Image(systemName: "paintpalette.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(store.project.name)
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("v\(store.project.version) • \(store.project.author)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Text(store.project.description)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(2)
                }
                .padding(.vertical, 4)
            }
            
            // MARK: - Built-in Presets
            Section("Built-in Presets") {
                ForEach(PresetTemplate.allCases) { preset in
                    Button {
                        store.loadPreset(preset)
                    } label: {
                        HStack {
                            Label(preset.rawValue, systemImage: preset.iconName)
                            Spacer()
                            if store.activePreset == preset {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.accentColor)
                                    .font(.caption)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(store.activePreset == preset ? Color.accentColor : Color.primary)
                }
            }
            
            // MARK: - Custom Presets with Header + Button
            Section {
                ForEach(store.customPresets) { custom in
                    HStack {
                        Button {
                            store.loadCustomPreset(custom)
                        } label: {
                            HStack {
                                Label(custom.name, systemImage: "sparkles")
                                Spacer()
                                if store.activeCustomPresetID == custom.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.accentColor)
                                        .font(.caption)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(store.activeCustomPresetID == custom.id ? Color.accentColor : Color.primary)
                        
                        Button {
                            store.deleteCustomPreset(id: custom.id)
                        } label: {
                            Image(systemName: "trash")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .help("Delete Custom Preset")
                    }
                }
                
                Button {
                    showingSavePresetSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.accentColor)
                        Text("Save Current as Preset...")
                            .font(.caption.bold())
                            .foregroundStyle(Color.accentColor)
                    }
                }
                .buttonStyle(.plain)
            } header: {
                HStack {
                    Text("My Custom Presets")
                    Spacer()
                    Button {
                        showingSavePresetSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.caption.bold())
                            .foregroundStyle(Color.accentColor)
                    }
                    .buttonStyle(.plain)
                    .help("Save current design system as custom preset")
                }
            }
            
            // MARK: - Navigation Sections
            Section("Navigation") {
                ForEach(NavigationSection.allCases) { section in
                    Button {
                        selectedSection = section
                    } label: {
                        HStack {
                            Label(section.rawValue, systemImage: section.iconName)
                            Spacer()
                            if section == .tokens {
                                Text("\(store.project.tokens.count)")
                                    .font(.caption2.weight(.bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(Color.secondary.opacity(0.2)))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 2)
                    .foregroundStyle(selectedSection == section ? Color.accentColor : Color.primary)
                }
            }
            
            // MARK: - Filter by Token Type with Section & Row + Buttons
            if selectedSection == .tokens {
                Section {
                    Button {
                        store.selectedTypeFilter = nil
                    } label: {
                        HStack {
                            Label("All Types", systemImage: "square.grid.2x2")
                            Spacer()
                            if store.selectedTypeFilter == nil {
                                Image(systemName: "checkmark").font(.caption)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(store.selectedTypeFilter == nil ? Color.accentColor : Color.primary)
                    
                    ForEach(TokenType.allCases) { type in
                        let count = store.project.tokens.filter { $0.type == type }.count
                        HStack {
                            Button {
                                store.selectedTypeFilter = (store.selectedTypeFilter == type) ? nil : type
                            } label: {
                                HStack {
                                    Label(type.rawValue, systemImage: type.iconName)
                                    Spacer()
                                    Text("\(count)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(store.selectedTypeFilter == type ? Color.accentColor : Color.primary)
                            
                            // Contextual + Button for this specific token type
                            Button {
                                onAddToken(type)
                            } label: {
                                Image(systemName: "plus.circle")
                                    .font(.caption)
                                    .foregroundStyle(Color.accentColor.opacity(0.8))
                            }
                            .buttonStyle(.plain)
                            .help("Add new \(type.rawValue) Token")
                        }
                    }
                } header: {
                    HStack {
                        Text("Filter by Type")
                        Spacer()
                        Button {
                            onAddToken(store.selectedTypeFilter)
                        } label: {
                            Image(systemName: "plus")
                                .font(.caption.bold())
                                .foregroundStyle(Color.accentColor)
                        }
                        .buttonStyle(.plain)
                        .help("Add Token")
                    }
                }
                
                // MARK: - Filter by Group
                Section("Groups") {
                    Button {
                        store.selectedGroupFilter = nil
                    } label: {
                        HStack {
                            Text("All Groups")
                            Spacer()
                            if store.selectedGroupFilter == nil {
                                Image(systemName: "checkmark").font(.caption)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    
                    ForEach(store.project.tokenGroups, id: \.self) { group in
                        Button {
                            store.selectedGroupFilter = (store.selectedGroupFilter == group) ? nil : group
                        } label: {
                            HStack {
                                Image(systemName: "folder.fill")
                                    .font(.caption)
                                    .foregroundStyle(Color.orange)
                                Text(group)
                                Spacer()
                                if store.selectedGroupFilter == group {
                                    Image(systemName: "checkmark").font(.caption)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(store.selectedGroupFilter == group ? Color.accentColor : Color.primary)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .sheet(isPresented: $showingSavePresetSheet) {
            SavePresetSheetView(store: store)
        }
    }
}
