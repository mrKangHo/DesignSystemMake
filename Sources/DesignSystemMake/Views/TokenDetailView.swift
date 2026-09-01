import SwiftUI

public struct TokenDetailView: View {
    @ObservedObject var store: ProjectStore
    @Binding var token: DesignToken
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // MARK: - Header / Identifier Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: token.type.iconName)
                            .font(.title2)
                            .foregroundStyle(Color.accentColor)
                        Text(token.displayName)
                            .font(.title2.weight(.bold))
                        Spacer()
                        
                        Button(role: .destructive) {
                            store.deleteToken(id: token.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .buttonStyle(.borderless)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("TOKEN IDENTIFIER")
                            .font(.caption2.bold())
                            .foregroundStyle(.tertiary)
                        TextField("Identifier (e.g. color.brand.primary)", text: $token.name)
                            .textFieldStyle(.roundedBorder)
                            .font(.body.monospaced())
                    }
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("DISPLAY NAME")
                                .font(.caption2.bold())
                                .foregroundStyle(.tertiary)
                            TextField("Display Name", text: $token.displayName)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("GROUP")
                                .font(.caption2.bold())
                                .foregroundStyle(.tertiary)
                            TextField("Group Name", text: $token.groupName)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DESCRIPTION")
                            .font(.caption2.bold())
                            .foregroundStyle(.tertiary)
                        TextField("Token description...", text: $token.description)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Divider()
                
                // MARK: - Type Specific Editor
                switch token.type {
                case .color:
                    ColorTokenEditorView(token: $token)
                case .typography:
                    TypographyTokenEditorView(token: $token)
                case .spacing:
                    SpacingTokenEditorView(token: $token)
                case .radius:
                    RadiusTokenEditorView(token: $token)
                case .shadow:
                    ShadowTokenEditorView(token: $token)
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Color Token Editor
struct ColorTokenEditorView: View {
    @Binding var token: DesignToken
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("COLOR VALUE & VARIANTS")
                .font(.headline)
            
            if var val = token.colorValue {
                HStack(spacing: 20) {
                    // Light Mode Color
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Light Mode Hex")
                            .font(.caption.bold())
                        
                        HStack {
                            ColorPicker("", selection: Binding(
                                get: { Color(hex: val.lightHex) },
                                set: { newColor in
                                    val.lightHex = ContrastCalculator.colorToHex(newColor)
                                    token.colorValue = val
                                }
                            ))
                            .labelsHidden()
                            
                            TextField("#Hex", text: Binding(
                                get: { val.lightHex },
                                set: { val.lightHex = $0; token.colorValue = val }
                            ))
                            .textFieldStyle(.roundedBorder)
                            .font(.callout.monospaced())
                        }
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: val.lightHex))
                            .frame(height: 70)
                            .overlay(
                                Text(val.lightHex)
                                    .font(.caption.monospaced().bold())
                                    .foregroundStyle(ContrastCalculator.evaluateContrast(foregroundHex: val.lightHex, backgroundHex: "#000000").contrastRatio > 4.5 ? .white : .black)
                            )
                    }
                    
                    // Dark Mode Variant
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Dark Mode Hex (Optional)")
                            .font(.caption.bold())
                        
                        HStack {
                            ColorPicker("", selection: Binding(
                                get: { Color(hex: val.effectiveDarkHex) },
                                set: { newColor in
                                    val.darkHex = ContrastCalculator.colorToHex(newColor)
                                    token.colorValue = val
                                }
                            ))
                            .labelsHidden()
                            
                            TextField("#Hex", text: Binding(
                                get: { val.darkHex ?? "" },
                                set: { val.darkHex = $0.isEmpty ? nil : $0; token.colorValue = val }
                            ))
                            .textFieldStyle(.roundedBorder)
                            .font(.callout.monospaced())
                        }
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(hex: val.effectiveDarkHex))
                            .frame(height: 70)
                            .overlay(
                                Text(val.effectiveDarkHex)
                                    .font(.caption.monospaced().bold())
                                    .foregroundStyle(ContrastCalculator.evaluateContrast(foregroundHex: val.effectiveDarkHex, backgroundHex: "#000000").contrastRatio > 4.5 ? .white : .black)
                            )
                    }
                }
                
                // WCAG Accessibility Matrix
                VStack(alignment: .leading, spacing: 10) {
                    Text("WCAG 2.1 CONTRAST ANALYSIS")
                        .font(.caption.bold())
                        .foregroundStyle(.tertiary)
                    
                    let bgLight = ContrastCalculator.evaluateContrast(foregroundHex: val.lightHex, backgroundHex: "#FFFFFF")
                    let bgDark = ContrastCalculator.evaluateContrast(foregroundHex: val.lightHex, backgroundHex: "#0F172A")
                    
                    HStack(spacing: 16) {
                        ContrastCard(title: "vs White Canvas (#FFFFFF)", result: bgLight)
                        ContrastCard(title: "vs Dark Canvas (#0F172A)", result: bgDark)
                    }
                }
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ContrastCard: View {
    let title: String
    let result: WCAGResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(result.formattedRatio)
                .font(.title3.bold().monospaced())
                .foregroundStyle(result.passesAANormal ? .green : .orange)
            
            HStack(spacing: 6) {
                StatusTag(label: "AA Normal", pass: result.passesAANormal)
                StatusTag(label: "AA Large", pass: result.passesAALarge)
                StatusTag(label: "AAA Normal", pass: result.passesAAANormal)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(nsColor: .windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct StatusTag: View {
    let label: String
    let pass: Bool
    
    var body: some View {
        Text("\(label): \(pass ? "PASS" : "FAIL")")
            .font(.caption2.bold())
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(pass ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
            .foregroundStyle(pass ? Color.green : Color.red)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

// MARK: - Typography Editor
struct TypographyTokenEditorView: View {
    @Binding var token: DesignToken
    @State private var isCustomFont: Bool = false
    
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("TYPOGRAPHY PROPERTIES")
                .font(.headline)
            
            if var val = token.typographyValue {
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                    GridRow {
                        Text("Font Family").font(.caption.bold())
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Picker("", selection: Binding(
                                    get: { val.fontFamily },
                                    set: { val.fontFamily = $0; token.typographyValue = val }
                                )) {
                                    ForEach(fontPresets, id: \.self) { font in
                                        Text(font).tag(font)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(width: 180)
                                
                                TextField("Custom font...", text: Binding(
                                    get: { val.fontFamily },
                                    set: { val.fontFamily = $0; token.typographyValue = val }
                                ))
                                .textFieldStyle(.roundedBorder)
                            }
                        }
                    }
                    
                    GridRow {
                        Text("Font Size").font(.caption.bold())
                        HStack {
                            Slider(value: Binding(
                                get: { val.fontSize },
                                set: { val.fontSize = $0; token.typographyValue = val }
                            ), in: 8...72, step: 1)
                            Text("\(Int(val.fontSize)) pt").font(.callout.monospaced()).frame(width: 50)
                        }
                    }
                    
                    GridRow {
                        Text("Weight").font(.caption.bold())
                        Picker("", selection: Binding(
                            get: { val.fontWeight },
                            set: { val.fontWeight = $0; token.typographyValue = val }
                        )) {
                            Text("Regular").tag("Regular")
                            Text("Medium").tag("Medium")
                            Text("SemiBold").tag("SemiBold")
                            Text("Bold").tag("Bold")
                        }
                        .pickerStyle(.segmented)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("LIVE SAMPLE")
                        .font(.caption.bold())
                        .foregroundStyle(.tertiary)
                    Text("The quick brown fox jumps over the lazy dog.")
                        .font(.custom(val.fontFamily, size: val.fontSize))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(nsColor: .windowBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Spacing Editor
struct SpacingTokenEditorView: View {
    @Binding var token: DesignToken
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SPACING PROPERTY")
                .font(.headline)
            
            if var val = token.spacingValue {
                HStack(spacing: 16) {
                    Slider(value: Binding(
                        get: { val.value },
                        set: { val.value = $0; token.spacingValue = val }
                    ), in: 0...96, step: 2)
                    
                    Text("\(Int(val.value)) \(val.unit)")
                        .font(.headline.monospaced())
                        .frame(width: 70)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("VISUAL SCALE PREVIEW")
                        .font(.caption.bold())
                        .foregroundStyle(.tertiary)
                    
                    HStack(spacing: val.value) {
                        ForEach(0..<4) { index in
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.blue)
                                .frame(width: 40, height: 40)
                                .overlay(Text("\(index + 1)").font(.caption.bold()).foregroundStyle(.white))
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color(nsColor: .windowBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Radius Editor
struct RadiusTokenEditorView: View {
    @Binding var token: DesignToken
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("BORDER RADIUS")
                .font(.headline)
            
            if var val = token.radiusValue {
                HStack(spacing: 16) {
                    Slider(value: Binding(
                        get: { val.value },
                        set: { val.value = $0; token.radiusValue = val }
                    ), in: 0...40, step: 1)
                    
                    Text("\(Int(val.value)) px")
                        .font(.headline.monospaced())
                        .frame(width: 60)
                }
                
                RoundedRectangle(cornerRadius: val.value)
                    .fill(Color.purple.opacity(0.2))
                    .overlay(RoundedRectangle(cornerRadius: val.value).stroke(Color.purple, lineWidth: 2))
                    .frame(width: 120, height: 120)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Shadow Editor
struct ShadowTokenEditorView: View {
    @Binding var token: DesignToken
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SHADOW PROPERTIES")
                .font(.headline)
            
            if var val = token.shadowValue {
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 12) {
                    GridRow {
                        Text("Blur Radius").font(.caption.bold())
                        Slider(value: Binding(
                            get: { val.blur },
                            set: { val.blur = $0; token.shadowValue = val }
                        ), in: 0...40)
                        Text("\(Int(val.blur)) px").font(.callout.monospaced()).frame(width: 50)
                    }
                    GridRow {
                        Text("Y Offset").font(.caption.bold())
                        Slider(value: Binding(
                            get: { val.y },
                            set: { val.y = $0; token.shadowValue = val }
                        ), in: -20...30)
                        Text("\(Int(val.y)) px").font(.callout.monospaced()).frame(width: 50)
                    }
                }
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .shadow(color: Color(hex: val.colorHex).opacity(val.opacity), radius: val.blur, x: val.x, y: val.y)
                    .frame(width: 140, height: 90)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
