// swift-tools-version:5.3.0
import PackageDescription

let package = Package(
    name: "Validation",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "validator", targets: ["Validator", "LinkValidator"])
    ],
    targets: [
        .target(name: "Validator", dependencies: ["LinkValidator"]),
        .target(name: "LinkValidator"),
        .testTarget(name: "LinkValidatorTests",
                    dependencies: ["LinkValidator"],
                    resources: [
                        .copy("Resources/validLinks.md"),
                        .copy("Resources/invalidLinks.md"),
                        .copy("Resources/extractLinksFromText.md")
                    ])
    ]
)
