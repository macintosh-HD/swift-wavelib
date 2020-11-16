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
                "wavelib/test",
                "wavelib/unitTests",
                "wavelib/CMakeLists.txt",
                "wavelib/src/CMakeLists.txt",
                "wavelib/auxiliary/CMakeLists.txt",
                "wavelib/COPYRIGHT",
                "wavelib/appveyor.yml",
                "wavelib/wavelib-doc.pdf",
                "wavelib/README.md"
            ],
            cSettings: [
                .headerSearchPath("wavelib/src"),
                .headerSearchPath("wavelib/header")
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
