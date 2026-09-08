import SwiftUI
import AppKit

public struct NewTokenSheetView: View {
    @ObservedObject var store: ProjectStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var displayName: String
    @State private var type: TokenType
    @State private var groupName: String
    @State private var descriptionText: String = ""
    
    // Color Value
    @State private var lightHex: String = "#3B82F6"
    
    // Typography Values
    @State private var fontFamily: String = "SF Pro"
    @State private var fontSize: Double = 16
    @State private var fontWeight: String = "Regular"
    @State private var lineHeight: Double = 24
    @State private var isCustomFont: Bool = false
    
    // Spacing & Radius Values
    @State private var spacingValue: Double = 16
    @State private var radiusValue: Double = 8
    
    private let fontPresets = [
        "SF Pro",
        "SF Pro Display",
        "SF Pro Text",
        "SF Mono",
        "Inter",
        "Roboto",
        "Helvetica Neue",
        "Arial",
        "Courier New",
        "Georgia"
    ]
    
    public init(store: ProjectStore, initialType: TokenType? = nil) {
        self.store = store
        let t = initialType ?? .color
        _type = State(initialValue: t)
        
        switch t {
        case .color:
            _name = State(initialValue: "color.brand.new")
            _displayName = State(initialValue: "New Brand Color")
            _groupName = State(initialValue: "Brand")
        case .typography:
            _name = State(initialValue: "typography.body.custom")
            _displayName = State(initialValue: "Custom Text Style")
            _groupName = State(initialValue: "Body Copy")
        case .spacing:
            _name = State(initialValue: "spacing.custom")
            _displayName = State(initialValue: "Custom Space 16px")
            _groupName = State(initialValue: "Scale")
        case .radius:
            _name = State(initialValue: "radius.custom")
            _displayName = State(initialValue: "Custom Radius 8px")
            _groupName = State(initialValue: "Corners")
        case .shadow:
            _name = State(initialValue: "shadow.custom")
            _displayName = State(initialValue: "Custom Card Shadow")
            _groupName = State(initialValue: "Elevation")
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Create New \(type.rawValue) Token")
                .font(.title2.bold())
            
            Form {
                Picker("Token Type", selection: $type) {
                    ForEach(TokenType.allCases) { t in
                        Label(t.rawValue, systemImage: t.iconName).tag(t)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: type) { _, newType in
                    switch newType {
                    case .color:
                        name = "color.brand.new"
                        displayName = "New Brand Color"
                        groupName = "Brand"
                    case .typography:
                        name = "typography.body.custom"
                        displayName = "Custom Text Style"
                        groupName = "Body Copy"
                    case .spacing:
                        name = "spacing.custom"
                        displayName = "Custom Space 16px"
                        groupName = "Scale"
                    case .radius:
                        name = "radius.custom"
                        displayName = "Custom Radius 8px"
                        groupName = "Corners"
                    case .shadow:
                        name = "shadow.custom"
                        displayName = "Custom Card Shadow"
                        groupName = "Elevation"
                    }
                }
                
                Section("Metadata") {
                    TextField("Display Name", text: $displayName)
                    TextField("Token Identifier", text: $name)
                    TextField("Group Name", text: $groupName)
                    TextField("Description", text: $descriptionText)
                }
                
                Section("Initial Value Configuration") {
                    switch type {
                    case .color:
                        HStack {
                            ColorPicker("Light Mode Color", selection: Binding(
                                get: { Color(hex: lightHex) },
                                set: { lightHex = ContrastCalculator.colorToHex($0) }
                            ))
                            TextField("#Hex", text: $lightHex)
                                .textFieldStyle(.roundedBorder)
                                .font(.callout.monospaced())
                        }
                        
                    case .typography:
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Font Family")
                                    .font(.caption.bold())
                                Spacer()
                                Toggle("Custom Name", isOn: $isCustomFont)
                                    .toggleStyle(.checkbox)
                                    .font(.caption)
                            }
                            
                            if isCustomFont {
                                TextField("Enter font family (e.g. Fira Code)", text: $fontFamily)
                                    .textFieldStyle(.roundedBorder)
                            } else {
                                Picker("", selection: $fontFamily) {
                                    ForEach(fontPresets, id: \.self) { font in
                                        Text(font).tag(font)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                            
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Size (\(Int(fontSize)) pt)").font(.caption.bold())
                                    Slider(value: $fontSize, in: 8...72, step: 1)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Weight").font(.caption.bold())
                                    Picker("", selection: $fontWeight) {
                                        Text("Regular").tag("Regular")
                                        Text("Medium").tag("Medium")
                                        Text("SemiBold").tag("SemiBold")
                                        Text("Bold").tag("Bold")
                                    }
                                    .pickerStyle(.segmented)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("SAMPLE PREVIEW")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.tertiary)
                                Text("The quick brown fox jumps over the lazy dog")
                                    .font(.custom(fontFamily, size: fontSize))
                                    .lineLimit(1)
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(nsColor: .controlBackgroundColor))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                        }
                        
                    case .spacing:
                        HStack {
                            Slider(value: $spacingValue, in: 0...64, step: 2)
                            Text("\(Int(spacingValue)) px")
                        }
                    case .radius:
                        HStack {
                            Slider(value: $radiusValue, in: 0...32, step: 1)
                            Text("\(Int(radiusValue)) px")
                        }
                    case .shadow:
                        Text("Default Elevated Card Shadow initialized")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .formStyle(.grouped)
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Create Token") {
                    createNewToken()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 520, height: 500)
    }
    
    private func createNewToken() {
        var colorVal: ColorTokenValue? = nil
        var spacingVal: SpacingTokenValue? = nil
        var radiusVal: RadiusTokenValue? = nil
        var typographyVal: TypographyTokenValue? = nil
        var shadowVal: ShadowTokenValue? = nil
        
        switch type {
        case .color:
            colorVal = ColorTokenValue(lightHex: lightHex)
        case .spacing:
            spacingVal = SpacingTokenValue(value: spacingValue)
        case .radius:
            radiusVal = RadiusTokenValue(value: radiusValue)
        case .typography:
            typographyVal = TypographyTokenValue(
                fontFamily: fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                lineHeight: fontSize * 1.3
            )
        case .shadow:
            shadowVal = ShadowTokenValue()
        }
        
        let token = DesignToken(
            name: name,
            displayName: displayName,
            type: type,
            description: descriptionText,
            groupName: groupName,
            colorValue: colorVal,
            typographyValue: typographyVal,
            spacingValue: spacingVal,
            radiusValue: radiusVal,
            shadowValue: shadowVal
        )
        
        store.addToken(token)
    }
}
