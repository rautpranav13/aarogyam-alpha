// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "cloud_firestore", path: "../.packages/cloud_firestore-5.6.10"),
        .package(name: "firebase_auth", path: "../.packages/firebase_auth-5.6.1"),
        .package(name: "firebase_core", path: "../.packages/firebase_core-3.15.0"),
        .package(name: "firebase_storage", path: "../.packages/firebase_storage-12.4.8"),
        .package(name: "flutter_native_splash", path: "../.packages/flutter_native_splash-2.4.4"),
        .package(name: "image_picker_ios", path: "../.packages/image_picker_ios-0.8.12"),
        .package(name: "path_provider_foundation", path: "../.packages/path_provider_foundation-2.4.0"),
        .package(name: "shared_preferences_foundation", path: "../.packages/shared_preferences_foundation-2.5.2"),
        .package(name: "url_launcher_ios", path: "../.packages/url_launcher_ios-6.3.1"),
        .package(name: "video_player_avfoundation", path: "../.packages/video_player_avfoundation-2.6.2"),
        .package(name: "FlutterFramework", path: "../.packages/FlutterFramework")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "cloud-firestore", package: "cloud_firestore"),
                .product(name: "firebase-auth", package: "firebase_auth"),
                .product(name: "firebase-core", package: "firebase_core"),
                .product(name: "firebase-storage", package: "firebase_storage"),
                .product(name: "flutter-native-splash", package: "flutter_native_splash"),
                .product(name: "image-picker-ios", package: "image_picker_ios"),
                .product(name: "path-provider-foundation", package: "path_provider_foundation"),
                .product(name: "shared-preferences-foundation", package: "shared_preferences_foundation"),
                .product(name: "url-launcher-ios", package: "url_launcher_ios"),
                .product(name: "video-player-avfoundation", package: "video_player_avfoundation"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
