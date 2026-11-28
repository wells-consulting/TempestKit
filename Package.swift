// swift-tools-version: 6.2
//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import PackageDescription

let package = Package(
    name: "TempestKit",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
    ],
    products: [
        .library(name: "TempestKit", targets: ["TempestKit"]),
        // The station's broadcasts, on the local network. Separate so the
        // main product stays Foundation only and the Linux build stays green.
        .library(name: "TempestKitUDP", targets: ["TempestKitUDP"]),
        // The live feed. Separate because it holds a connection open and
        // because URLSessionWebSocketTask needs a libcurl with WebSockets on
        // Linux.
        .library(name: "TempestKitWebSocket", targets: ["TempestKitWebSocket"]),
    ],
    targets: [
        .target(
            name: "TempestKit",
            swiftSettings: [
                // Nonisolated async runs on the caller's actor in 6.2. The
                // network and decode work says `@concurrent` so it stays off
                // the caller's actor instead.
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            ],
        ),
        .target(
            name: "TempestKitUDP",
            dependencies: ["TempestKit"],
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            ],
        ),
        .target(
            name: "TempestKitWebSocket",
            dependencies: ["TempestKit"],
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            ],
        ),
        .testTarget(name: "TempestKitTests", dependencies: ["TempestKit"]),
        .testTarget(
            name: "TempestKitUDPTests",
            dependencies: ["TempestKit", "TempestKitUDP"],
        ),
        .testTarget(
            name: "TempestKitWebSocketTests",
            dependencies: ["TempestKit", "TempestKitWebSocket"],
        ),
    ],
)
