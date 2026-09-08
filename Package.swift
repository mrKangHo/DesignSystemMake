// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DesignSystemMake",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "DesignSystemMake",
            resources: [
                .copy("Resources/AppIcon.png"),
                .copy("Resources/AppIcon.jpg")
            ]
        )
    ]
)
