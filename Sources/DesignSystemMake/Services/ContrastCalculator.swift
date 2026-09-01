import Foundation
import SwiftUI

public struct WCAGResult {
    public let contrastRatio: Double
    public let passesAANormal: Bool
    public let passesAALarge: Bool
    public let passesAAANormal: Bool
    public let passesAAALarge: Bool
    
    public var formattedRatio: String {
        String(format: "%.2f:1", contrastRatio)
    }
}

public class ContrastCalculator {
    
    /// Parse hex string (#RGB, #RRGGBB, #RRGGBBAA) to RGB components [0...1]
    public static func parseHex(_ hex: String) -> (r: Double, g: Double, b: Double, a: Double)? {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanHex.hasPrefix("#") {
            cleanHex.removeFirst()
        }
        
        var hexValue: UInt64 = 0
        guard Scanner(string: cleanHex).scanHexInt64(&hexValue) else { return nil }
        
        var r, g, b, a: Double
        switch cleanHex.count {
        case 3: // RGB
            r = Double((hexValue >> 8) & 0xF) / 15.0
            g = Double((hexValue >> 4) & 0xF) / 15.0
            b = Double(hexValue & 0xF) / 15.0
            a = 1.0
        case 6: // RRGGBB
            r = Double((hexValue >> 16) & 0xFF) / 255.0
            g = Double((hexValue >> 8) & 0xFF) / 255.0
            b = Double(hexValue & 0xFF) / 255.0
            a = 1.0
        case 8: // RRGGBBAA
            r = Double((hexValue >> 24) & 0xFF) / 255.0
            g = Double((hexValue >> 16) & 0xFF) / 255.0
            b = Double((hexValue >> 8) & 0xFF) / 255.0
            a = Double(hexValue & 0xFF) / 255.0
        default:
            return nil
        }
        return (r, g, b, a)
    }
    
    /// Convert Swift Color to Hex string
    public static func colorToHex(_ color: Color) -> String {
        guard let components = color.cgColor?.components, components.count >= 3 else {
            return "#000000"
        }
        let r = Int(round(components[0] * 255))
        let g = Int(round(components[1] * 255))
        let b = Int(round(components[2] * 255))
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    
    /// Calculate relative luminance for a given hex color
    public static func relativeLuminance(hex: String) -> Double {
        guard let rgb = parseHex(hex) else { return 0.0 }
        
        func linearize(_ val: Double) -> Double {
            if val <= 0.04045 {
                return val / 12.92
            } else {
                return pow((val + 0.055) / 1.055, 2.4)
            }
        }
        
        let rLin = linearize(rgb.r)
        let gLin = linearize(rgb.g)
        let bLin = linearize(rgb.b)
        
        return 0.2126 * rLin + 0.7152 * gLin + 0.0722 * bLin
    }
    
    /// Calculate WCAG 2.1 contrast ratio between text hex and background hex
    public static func evaluateContrast(foregroundHex: String, backgroundHex: String) -> WCAGResult {
        let l1 = relativeLuminance(hex: foregroundHex)
        let l2 = relativeLuminance(hex: backgroundHex)
        
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        
        let ratio = (lighter + 0.05) / (darker + 0.05)
        
        return WCAGResult(
            contrastRatio: ratio,
            passesAANormal: ratio >= 4.5,
            passesAALarge: ratio >= 3.0,
            passesAAANormal: ratio >= 7.0,
            passesAAALarge: ratio >= 4.5
        )
    }
}

// Global Color(hex:) Initializer
public extension Color {
    init(hex: String) {
        var cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if cleanHex.hasPrefix("#") { cleanHex.removeFirst() }
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)
        let r, g, b, a: Double
        switch cleanHex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
            a = 1.0
        default:
            r = 1.0; g = 1.0; b = 1.0; a = 1.0
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
