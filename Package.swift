// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "ReusableView",  
    platforms: [
        .iOS(.v12),  
        .macOS(.v11) 
    ],
    products: [
        .library(
            name: "ReusableView", 
            targets: ["ReusableView"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.0.0"))
    ],
    targets: [
        .target(
            name: "ReusableView",
            dependencies: ["RxSwift"] 
        )
    ],
    swiftLanguageModes: [.v5]
)
