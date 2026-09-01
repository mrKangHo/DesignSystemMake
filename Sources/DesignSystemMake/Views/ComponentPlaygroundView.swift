import SwiftUI

public struct ComponentPlaygroundView: View {
    @ObservedObject var store: ProjectStore
    @State private var isDarkMode: Bool = false
    @State private var sampleInputText: String = "Jane Doe"
    @State private var toggleState: Bool = true
    @State private var sliderVal: Double = 65
    @State private var selectedSegment: Int = 0
    
    // Quick Token Helpers
    private var primaryColor: Color {
        if let token = store.project.tokens.first(where: { $0.name == "color.brand.primary" }),
           let val = token.colorValue {
            return Color(hex: isDarkMode ? val.effectiveDarkHex : val.lightHex)
        }
        return .blue
    }
    
    private var secondaryColor: Color {
        if let token = store.project.tokens.first(where: { $0.name == "color.brand.secondary" }),
           let val = token.colorValue {
            return Color(hex: isDarkMode ? val.effectiveDarkHex : val.lightHex)
        }
        return .indigo
    }
    
    private var surfaceColor: Color {
        if let token = store.project.tokens.first(where: { $0.name == "color.neutral.surface" }),
           let val = token.colorValue {
            return Color(hex: isDarkMode ? val.effectiveDarkHex : val.lightHex)
        }
        return isDarkMode ? Color(hex: "#1E293B") : .white
    }
    
    private var textPrimaryColor: Color {
        if let token = store.project.tokens.first(where: { $0.name == "color.neutral.textPrimary" }),
           let val = token.colorValue {
            return Color(hex: isDarkMode ? val.effectiveDarkHex : val.lightHex)
        }
        return isDarkMode ? .white : Color(hex: "#0F172A")
    }
    
    private var cornerRadius: CGFloat {
        if let token = store.project.tokens.first(where: { $0.name == "radius.card" || $0.name == "radius.md" }),
           let val = token.radiusValue {
            return val.value
        }
        return 12
    }
    
    private var spacingMd: CGFloat {
        if let token = store.project.tokens.first(where: { $0.name == "spacing.md" }),
           let val = token.spacingValue {
            return val.value
        }
        return 16
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Control Header Bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Component Playground")
                        .font(.title2.bold())
                        .tracking(-0.3)
                    Text("Live UI preview rendered directly with active tokens")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Theme Toggle
                Toggle(isOn: $isDarkMode) {
                    HStack(spacing: 6) {
                        Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                            .foregroundStyle(isDarkMode ? .yellow : .orange)
                        Text(isDarkMode ? "Dark Mode" : "Light Mode")
                            .font(.callout.bold())
                    }
                }
                .toggleStyle(.switch)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Material.bar)
            
            Divider()
            
            // Canvas Area
            ScrollView {
                VStack(spacing: 28) {
                    // MARK: - 1. Button Matrix
                    PlaygroundSection(title: "1. Buttons & Action Controls") {
                        HStack(spacing: 16) {
                            // Primary Action Button
                            Button {} label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Primary Action")
                                }
                                .fontWeight(.bold)
                                .padding(.horizontal, spacingMd)
                                .padding(.vertical, 10)
                                .background(primaryColor)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                                .shadow(color: primaryColor.opacity(0.3), radius: 6, x: 0, y: 3)
                            }
                            .buttonStyle(.plain)
                            
                            // Secondary Button
                            Button {} label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "sparkles")
                                    Text("Secondary")
                                }
                                .fontWeight(.semibold)
                                .padding(.horizontal, spacingMd)
                                .padding(.vertical, 10)
                                .background(secondaryColor.opacity(0.15))
                                .foregroundStyle(secondaryColor)
                                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            
                            // Outline Button
                            Button {} label: {
                                Text("Outline Style")
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, spacingMd)
                                    .padding(.vertical, 10)
                                    .background(surfaceColor)
                                    .foregroundStyle(textPrimaryColor)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                            .stroke(primaryColor, lineWidth: 1.5)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // MARK: - 2. Segmented Control & Inputs
                    PlaygroundSection(title: "2. Form Controls & Sliders") {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 24) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("SEGMENTED SELECTION")
                                        .font(.caption2.bold())
                                        .foregroundStyle(.tertiary)
                                    
                                    Picker("", selection: $selectedSegment) {
                                        Text("Overview").tag(0)
                                        Text("Tokens").tag(1)
                                        Text("Export").tag(2)
                                    }
                                    .pickerStyle(.segmented)
                                    .frame(width: 260)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("ACCENT SLIDER (\(Int(sliderVal))%)")
                                        .font(.caption2.bold())
                                        .foregroundStyle(.tertiary)
                                    
                                    Slider(value: $sliderVal, in: 0...100)
                                        .tint(primaryColor)
                                        .frame(width: 220)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("FULL NAME INPUT")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.tertiary)
                                
                                TextField("Enter user name...", text: $sampleInputText)
                                    .padding(10)
                                    .background(surfaceColor)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                            .stroke(primaryColor.opacity(0.8), lineWidth: 1.5)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                                    .foregroundStyle(textPrimaryColor)
                            }
                            .frame(maxWidth: 360)
                        }
                    }
                    
                    // MARK: - 3. Elevated Cards
                    PlaygroundSection(title: "3. Elevated Surface Cards & Badges") {
                        HStack(spacing: 20) {
                            // User Profile Card Specimen
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(primaryColor)
                                        .frame(width: 46, height: 46)
                                        .overlay(
                                            Text("JD")
                                                .font(.headline.bold())
                                                .foregroundStyle(.white)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Jane Doe")
                                            .font(.headline.bold())
                                            .foregroundStyle(textPrimaryColor)
                                        Text("Lead Product Designer")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    
                                    BadgeTag(text: "PRO DESIGNER", color: primaryColor)
                                }
                                
                                Text("Token-driven elevated container specimen utilizing active colors, corner radius tokens, and ambient shadows.")
                                    .font(.subheadline)
                                    .foregroundStyle(textPrimaryColor.opacity(0.85))
                                    .lineSpacing(4)
                                
                                HStack(spacing: 8) {
                                    BadgeTag(text: "SUCCESS", color: Color.green)
                                    BadgeTag(text: "WARNING", color: Color.orange)
                                    BadgeTag(text: "DANGER", color: Color.red)
                                }
                            }
                            .padding(spacingMd)
                            .background(surfaceColor)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(isDarkMode ? 0.4 : 0.08), radius: 16, x: 0, y: 6)
                        }
                    }
                }
                .padding(28)
            }
            .background(isDarkMode ? Color(hex: "#0F172A") : Color(hex: "#F8FAFC"))
        }
    }
}

struct PlaygroundSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title.uppercased())
                .font(.system(.caption, design: .monospaced).bold())
                .foregroundStyle(.secondary)
                .tracking(0.5)
            
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct BadgeTag: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(.caption2, design: .monospaced).bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.16))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}
