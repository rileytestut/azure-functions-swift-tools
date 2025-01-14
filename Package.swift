// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swiftfunc",
    products: [
        .executable(name: "swiftfunc", targets: ["swiftfunc"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
        .package(url: "https://github.com/stencilproject/Stencil.git", from: "0.13.1"),
        .package(url: "https://github.com/rileytestut/swift-package-manager.git", .branchItem("azure")),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        // .target(
        //     name: "BSD",
        //     dependencies: []),
        .target(
            name: "swiftfunc",
            dependencies: ["Files", "Stencil", "SwiftPM", "Rainbow"]),
            //linkerSettings: [LinkerSetting.unsafeFlags(["-L./Sources/libEonilPTY"])],
        .testTarget(
            name: "swiftfuncTests",
            dependencies: ["swiftfunc"]),
    ]
)
