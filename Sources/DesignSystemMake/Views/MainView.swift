import SwiftUI

public struct MainView: View {
    @StateObject private var store = ProjectStore()
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var selectedSection: NavigationSection = .tokens
    @State private var showingNewTokenSheet: Bool = false
    @State private var targetTokenTypeForSheet: TokenType? = nil
    
    public init() {}
    
    private func openAddTokenSheet(type: TokenType?) {
        targetTokenTypeForSheet = type
        showingNewTokenSheet = true
    }
    
    public var body: some View {
        NavigationSplitView {
            SidebarView(
                store: store,
                selectedSection: $selectedSection,
                onAddToken: { type in
                    openAddTokenSheet(type: type)
                }
            )
            .navigationSplitViewColumnWidth(min: 220, ideal: 250, max: 300)
        } content: {
            switch selectedSection {
            case .tokens:
                TokenListView(store: store, onAddToken: { type in
                    openAddTokenSheet(type: type)
                })
                .navigationSplitViewColumnWidth(min: 340, ideal: 440)
            case .playground:
                ComponentPlaygroundView(store: store)
            case .exporter:
                CodeExportView(store: store)
            }
        } detail: {
            if selectedSection == .tokens {
                if let selectedBinding = Binding($store.selectedToken) {
                    TokenDetailView(store: store, token: selectedBinding)
                } else {
                    ContentUnavailableView(
                        "No Token Selected",
                        systemImage: "slider.horizontal.3",
                        description: Text("Select a token from the list to view and edit its properties.")
                    )
                }
            } else {
                ContentUnavailableView(
                    "Inspect Mode Active",
                    systemImage: selectedSection.iconName,
                    description: Text("Switch to Tokens navigation to inspect individual design tokens.")
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Picker("Language", selection: $localizationManager.currentLanguage) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text("\(lang.flagIcon) \(lang.displayName)").tag(lang)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 140)
            }
        }
        .sheet(isPresented: $showingNewTokenSheet) {
            NewTokenSheetView(store: store, initialType: targetTokenTypeForSheet)
        }
    }
}
