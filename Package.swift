// swift-tools-version:5.4.0
import PackageDescription

let package = Package(
    name: "LinkValidator",
    targets: [
        .target(name: "LinkValidator"),
        .testTarget(name: "LinkValidatorTests",
                    dependencies: ["LinkValidator"])
    ]
)
