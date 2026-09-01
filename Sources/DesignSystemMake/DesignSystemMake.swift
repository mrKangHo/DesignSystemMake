import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        // Load transparent macOS Squircle AppIcon.png and set as macOS Dock Icon
        if let iconImage = loadAppIconImage() {
            NSApplication.shared.applicationIconImage = iconImage
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let window = NSApp.windows.first {
                window.makeKeyAndOrderFront(nil)
            }
        }
    }
    
    private func loadAppIconImage() -> NSImage? {
        if let bundleUrl = Bundle.module.url(forResource: "AppIcon", withExtension: "png"),
           let img = NSImage(contentsOf: bundleUrl) {
            return img
        }
        let directPath = "/Users/lee/Documents/DesignSystemMake/Sources/DesignSystemMake/Resources/AppIcon.png"
        return NSImage(contentsOfFile: directPath)
    }
}

@main
struct DesignSystemMakeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .frame(minWidth: 1020, minHeight: 680)
                .onAppear {
                    NSApp.setActivationPolicy(.regular)
                    NSApp.activate(ignoringOtherApps: true)
                }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .commands {
            SidebarCommands()
            ToolbarCommands()
        }
    }
}
