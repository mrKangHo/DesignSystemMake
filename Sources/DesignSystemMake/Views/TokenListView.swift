import SwiftUI

public struct TokenListView: View {
    @ObservedObject var store: ProjectStore
    var onAddToken: (TokenType?) -> Void
    @State private var isGridView: Bool = true
    @State private var copiedTokenID: UUID? = nil
    
    private let columns = [
        GridItem(.adaptive(minimum: 230, maximum: 310), spacing: 16)
    ]
    
    public var body: some View {
        VStack(spacing: 0) {
            // MARK: - Search & Filter Header Bar
            HStack(spacing: 12) {
                // Search Input with SF Pro Optics
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    
                    TextField("Search tokens by name, group, or description...", text: $store.searchQuery)
                        .textFieldStyle(.plain)
                        .font(.body)
                    
                    if !store.searchQuery.isEmpty {
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                store.searchQuery = ""
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
                
                // Layout Toggle (Grid vs List)
                Picker("Layout", selection: $isGridView) {
                    Image(systemName: "square.grid.2x2.fill").tag(true)
                    Image(systemName: "list.bullet").tag(false)
                }
                .pickerStyle(.segmented)
                .frame(width: 76)
                
                // Contextual + Add Token Button
                Button {
                    onAddToken(store.selectedTypeFilter)
                } label: {
                    Label(
                        store.selectedTypeFilter != nil ? "Add \(store.selectedTypeFilter!.rawValue)" : "Add Token",
                        systemImage: "plus"
                    )
                    .font(.callout.weight(.semibold))
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Material.bar)
            
            Divider()
            
            // MARK: - Content Body (Empty State vs Grid/List)
            if store.filteredTokens.isEmpty {
                VStack(spacing: 14) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 44, weight: .light))
                        .foregroundStyle(.tertiary)
                    
                    Text("No Matching Tokens")
                        .font(.title3.weight(.semibold))
                    
                    Text("No tokens matched '\(store.searchQuery)'. Try clearing filters or creating a new token.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 320)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    if isGridView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(store.filteredTokens) { token in
                                TokenCardView(
                                    token: token,
                                    isSelected: store.selectedTokenID == token.id,
                                    isCopied: copiedTokenID == token.id
                                ) {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        store.selectedTokenID = token.id
                                    }
                                } onCopy: {
                                    copyTokenCode(token)
                                }
                            }
                        }
                        .padding(16)
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(store.filteredTokens) { token in
                                TokenRowView(
                                    token: token,
                                    isSelected: store.selectedTokenID == token.id,
                                    isCopied: copiedTokenID == token.id
                                ) {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        store.selectedTokenID = token.id
                                    }
                                } onCopy: {
                                    copyTokenCode(token)
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
    }
    
    private func copyTokenCode(_ token: DesignToken) {
        let code = "Color.DesignTokens.\(token.name.replacingOccurrences(of: ".", with: "_"))"
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(code, forType: .string)
        
        withAnimation(.spring(response: 0.2)) {
            copiedTokenID = token.id
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if copiedTokenID == token.id {
                withAnimation(.easeInOut(duration: 0.2)) {
                    copiedTokenID = nil
                }
            }
        }
    }
}

// MARK: - Apple HIG Token Card View (Grid Item)
struct TokenCardView: View {
    let token: DesignToken
    let isSelected: Bool
    let isCopied: Bool
    let onSelect: () -> Void
    let onCopy: () -> Void
    
    @State private var isHovered: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Visual Preview Canvas Box
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    )
                
                switch token.type {
                case .color:
                    if let val = token.colorValue {
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(Color(hex: val.lightHex))
                            if let dark = val.darkHex, dark != val.lightHex {
                                Rectangle()
                                    .fill(Color(hex: dark))
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        )
                    }
                case .typography:
                    if let val = token.typographyValue {
                        Text("Aa")
                            .font(.custom(val.fontFamily, size: min(val.fontSize, 30)))
                            .fontWeight(fontWeight(val.fontWeight))
                            .foregroundStyle(.primary)
                    }
                case .spacing:
                    if let val = token.spacingValue {
                        HStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.blue)
                                .frame(width: max(val.value, 4), height: 26)
                            Text("\(Int(val.value))\(val.unit)")
                                .font(.system(.caption, design: .monospaced).bold())
                                .foregroundStyle(.secondary)
                        }
                    }
                case .radius:
                    if let val = token.radiusValue {
                        RoundedRectangle(cornerRadius: val.value, style: .continuous)
                            .stroke(Color.purple, lineWidth: 3)
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: val.value, style: .continuous)
                                    .fill(Color.purple.opacity(0.12))
                            )
                    }
                case .shadow:
                    if let val = token.shadowValue {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: Color(hex: val.colorHex).opacity(val.opacity), radius: val.blur, x: val.x, y: val.y)
                            .frame(width: 54, height: 38)
                    }
                }
            }
            .frame(height: 84)
            
            // Name & Category Badge
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
                    Text(token.displayName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: token.type.iconName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Text(token.name)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            // Metrics & Action Bar
            HStack {
                if token.type == .color, let val = token.colorValue {
                    Text(val.lightHex.uppercased())
                        .font(.system(.caption, design: .monospaced).weight(.semibold))
                    Spacer()
                    let result = ContrastCalculator.evaluateContrast(foregroundHex: val.lightHex, backgroundHex: "#FFFFFF")
                    BadgeView(text: result.formattedRatio, isPass: result.passesAANormal)
                } else if token.type == .typography, let val = token.typographyValue {
                    Text("\(val.fontFamily) \(Int(val.fontSize))pt")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer()
                } else if token.type == .spacing, let val = token.spacingValue {
                    Text("\(Int(val.value))\(val.unit)")
                        .font(.system(.caption, design: .monospaced))
                    Spacer()
                } else if token.type == .radius, let val = token.radiusValue {
                    Text("\(Int(val.value))px radius")
                        .font(.system(.caption, design: .monospaced))
                    Spacer()
                } else {
                    Text(token.groupName)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Spacer()
                }
                
                Button {
                    onCopy()
                } label: {
                    Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
                        .font(.caption)
                        .foregroundStyle(isCopied ? .green : (isHovered ? Color.accentColor : .secondary))
                        .padding(4)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help("Copy token code reference")
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isSelected ? Color.accentColor.opacity(0.12) : (isHovered ? Color(nsColor: .controlBackgroundColor) : Color(nsColor: .windowBackgroundColor)))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isSelected ? Color.accentColor : Color.primary.opacity(0.08), lineWidth: isSelected ? 2 : 1)
        )
        .shadow(color: Color.black.opacity(isHovered ? 0.06 : 0.02), radius: isHovered ? 8 : 2, x: 0, y: isHovered ? 4 : 1)
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            onSelect()
        }
    }
    
    private func fontWeight(_ weight: String) -> Font.Weight {
        switch weight.lowercased() {
        case "bold": return .bold
        case "semibold": return .semibold
        case "medium": return .medium
        default: return .regular
        }
    }
}

// MARK: - Apple HIG Token Row View (List Item)
struct TokenRowView: View {
    let token: DesignToken
    let isSelected: Bool
    let isCopied: Bool
    let onSelect: () -> Void
    let onCopy: () -> Void
    
    @State private var isHovered: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor))
                
                if token.type == .color, let val = token.colorValue {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(hex: val.lightHex))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        )
                } else {
                    Image(systemName: token.type.iconName)
                        .font(.callout)
                        .foregroundStyle(Color.accentColor)
                }
            }
            .frame(width: 38, height: 38)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(token.displayName)
                    .font(.body.weight(.medium))
                Text(token.name)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if token.type == .color, let val = token.colorValue {
                Text(val.lightHex.uppercased())
                    .font(.system(.callout, design: .monospaced))
                let result = ContrastCalculator.evaluateContrast(foregroundHex: val.lightHex, backgroundHex: "#FFFFFF")
                BadgeView(text: result.formattedRatio, isPass: result.passesAANormal)
            } else if token.type == .typography, let val = token.typographyValue {
                Text("\(val.fontFamily) \(Int(val.fontSize))pt")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if token.type == .spacing, let val = token.spacingValue {
                Text("\(Int(val.value))\(val.unit)")
                    .font(.system(.caption, design: .monospaced))
            } else if token.type == .radius, let val = token.radiusValue {
                Text("\(Int(val.value))px")
                    .font(.system(.caption, design: .monospaced))
            }
            
            Button {
                onCopy()
            } label: {
                Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
                    .font(.callout)
                    .foregroundStyle(isCopied ? .green : (isHovered ? Color.accentColor : .secondary))
                    .padding(4)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isSelected ? Color.accentColor.opacity(0.12) : (isHovered ? Color(nsColor: .controlBackgroundColor) : Color.clear))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
        )
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            onSelect()
        }
    }
}

// MARK: - WCAG Badge Helper (Apple Optic Badges)
struct BadgeView: View {
    let text: String
    let isPass: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(isPass ? Color.green : Color.orange)
                .frame(width: 6, height: 6)
            Text(text)
                .font(.system(.caption2, design: .monospaced).bold())
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(isPass ? Color.green.opacity(0.14) : Color.orange.opacity(0.14))
        )
    }
}
