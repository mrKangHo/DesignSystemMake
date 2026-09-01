import SwiftUI
import AppKit

public struct FigmaSyncSheetView: View {
    @ObservedObject var store: ProjectStore
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("figma_access_token") private var accessToken: String = ""
    @AppStorage("figma_file_url") private var fileUrl: String = ""
    
    @State private var isSyncing: Bool = false
    @State private var syncStatusMessage: String? = nil
    @State private var isSuccess: Bool = false
    
    @FocusState private var isTokenFocused: Bool
    
    public init(store: ProjectStore) {
        self.store = store
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "paperplane.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.purple)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Direct Figma API Auto-Sync")
                        .font(.title2.bold())
                    Text("Push design system tokens directly into your Figma File Variables in real time")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            // Form Fields
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("FIGMA PERSONAL ACCESS TOKEN (PAT)")
                            .font(.caption2.bold())
                            .foregroundStyle(.tertiary)
                        Spacer()
                        Link("Get Token from Figma Settings ↗", destination: URL(string: "https://www.figma.com/settings")!)
                            .font(.caption)
                    }
                    
                    SecureField("figd_...", text: $accessToken)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTokenFocused)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("FIGMA FILE URL OR FILE KEY")
                        .font(.caption2.bold())
                        .foregroundStyle(.tertiary)
                    
                    TextField("https://www.figma.com/design/aB1c2D3e4F5/My-Design-System", text: $fileUrl)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .padding(14)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            
            // Sync Status Result Banner
            if let msg = syncStatusMessage {
                HStack(spacing: 10) {
                    Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundStyle(isSuccess ? .green : .orange)
                    Text(msg)
                        .font(.callout)
                        .foregroundStyle(isSuccess ? .green : .primary)
                    Spacer()
                }
                .padding(12)
                .background(isSuccess ? Color.green.opacity(0.12) : Color.orange.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            
            // Action Buttons
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                .disabled(isSyncing)
                
                Spacer()
                
                Button {
                    performFigmaSync()
                } label: {
                    HStack(spacing: 6) {
                        if isSyncing {
                            ProgressView()
                                .controlSize(.small)
                            Text("Syncing to Figma...")
                        } else {
                            Image(systemName: "paperplane.fill")
                            Text("Sync Directly to Figma")
                        }
                    }
                    .fontWeight(.bold)
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .disabled(isSyncing || accessToken.isEmpty || fileUrl.isEmpty)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 520, height: 420)
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                if accessToken.isEmpty {
                    isTokenFocused = true
                }
            }
        }
    }
    
    private func performFigmaSync() {
        withAnimation {
            isSyncing = true
            syncStatusMessage = nil
        }
        
        FigmaAPIService.syncToFigma(
            project: store.project,
            accessToken: accessToken,
            fileKeyOrUrl: fileUrl
        ) { result in
            Task { @MainActor in
                withAnimation {
                    isSyncing = false
                    isSuccess = result.success
                    syncStatusMessage = result.message
                }
            }
        }
    }
}
