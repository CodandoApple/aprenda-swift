// swift-tools-version:5.3.0
import PackageDescription

let package = Package(
    name: "LinkValidator",
    targets: [
        .target(name: "LinkValidator", resources: [.copy("README.md")]),
        .testTarget(name: "LinkValidatorTests",
                    dependencies: ["LinkValidator"])
    ]
)
