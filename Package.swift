// swift-tools-version:5.3

import PackageDescription

let package = Package(
    
    name      : "swift-async_bluetooth",
    platforms : [ .iOS("15.4") ],
    products:
        [
            .library(
                name    : "AsyncBluetooth",
                targets : ["AsyncBluetooth"]
            ),
        ],
    dependencies: [],
    targets:
        [
            .target(
                name         : "AsyncBluetooth",
                dependencies : [],
                path         : "Sources"
            )
        ]

)
