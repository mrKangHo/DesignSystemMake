import SwiftUI
import AppKit

public struct SavePresetSheetView: View {
    @ObservedObject var store: ProjectStore
    @Environment(\.dismiss) private var dismiss
    @State private var presetName: String
    @FocusState private var isTextFieldFocused: Bool
    
    public init(store: ProjectStore) {
        self.store = store
        _presetName = State(initialValue: "\(store.project.name) Preset")
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
                Text("Save as Custom Preset")
                    .font(.title2.bold())
            }
            
            Text("Enter a name for your custom design system preset template. All current tokens, colors, and typography settings will be saved.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("PRESET NAME")
                    .font(.caption2.bold())
                    .foregroundStyle(.tertiary)
                
                TextField("e.g. My Dark Theme Preset", text: $presetName)
                    .textFieldStyle(.roundedBorder)
                    .font(.body)
                    .focused($isTextFieldFocused)
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Save Preset") {
                    let trimmed = presetName.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty {
                        store.saveCurrentAsCustomPreset(name: trimmed)
                    }
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 440, height: 230)
        .onAppear {
            NSApp.activate(ignoringOtherApps: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                if let window = NSApp.keyWindow ?? NSApp.windows.first {
                    window.makeKeyAndOrderFront(nil)
                }
                isTextFieldFocused = true
            }
        }
    }
}
