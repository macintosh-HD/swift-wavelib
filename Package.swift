// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "swift-wavelib",
    products: [
        .library(
            name: "Wavelib",
            targets: ["Wavelib"]),
    ],
    targets: [
        .target(
            name: "cwavelib",
            exclude: [
                "test",
                "unitTests",
                "CMakeLists.txt",
                "COPYRIGHT",
                "appveyor.yml",
                "wavelib-doc.pdf",
                "README.md"
            ],
            cSettings: [
                .headerSearchPath("src"),
                .headerSearchPath("header")
            ]
        ),
        .target(
            name: "Wavelib",
            dependencies: ["cwavelib"]),
        .testTarget(
            name: "WavelibTests",
            dependencies: ["Wavelib"]),
    ]
)
