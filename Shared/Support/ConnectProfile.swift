//
// Copyright (C) 2026 Acoustic, L.P. All rights reserved.
//
// Licensed under the Acoustic License (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy
// at https://www.acoustic.com/licenses/acoustic-license
//
// Sample app provided "as is", without warranty of any kind.
//

import Connect
import Foundation

/// A named SDK configuration an automated test picks when it launches the
/// sample, so one build can be run under several configurations.
///
/// The test passes the name as the launch argument `-connectProfile <name>`.
/// iOS puts a `-key value` launch argument into `UserDefaults.standard`, so
/// ``current`` reads it from there. With no argument, or an empty one, the
/// sample starts exactly as it does without this type.
///
/// | Name | What it changes |
/// |------|-----------------|
/// | `session-timeout-1m` | `SessionTimeout` is 1 minute instead of the SDK's 30 |
/// | `no-screenshots` | The sample's own layout, with `ScreenShot` off for every screen |
/// | `sdk-defaults` | ``ConnectConfig/Layout/basicAnalytics`` and none of the sample's advanced settings |
///
/// A name that matches none of these starts the sample as it does without a
/// profile, and ``statusText`` says so, so a test can tell a misspelt name from
/// a profile that took effect.
///
/// ## Example
/// ```swift
/// let profile = ConnectProfile.current
/// ConnectSDK.shared.enable(
///     with: ConnectConfig(
///         appKey: "YOUR_APP_KEY",
///         postURL: "YOUR_POST_URL",
///         layout: profile.layout,
///         advanced: profile.advanced(over: [:])
///     )
/// )
/// ```
enum ConnectProfile: Equatable {

    /// No launch argument: the sample's own configuration.
    case standard

    /// `session-timeout-1m`.
    case sessionTimeout1m

    /// `no-screenshots`.
    case noScreenshots

    /// `sdk-defaults`.
    case sdkDefaults

    /// A name the sample does not know. Nothing is applied.
    case unknown(String)

    /// The `UserDefaults` key a `-connectProfile <name>` launch argument lands in.
    static let launchArgumentKey = "connectProfile"

    /// The profile this launch asked for.
    static let current = ConnectProfile(name: UserDefaults.standard.string(forKey: launchArgumentKey))

    /// Resolves a profile name.
    ///
    /// - Parameter name: The launch argument's value, or `nil` when absent.
    ///   `nil` and an empty string both give ``standard``.
    init(name: String?) {
        switch name {
        case nil, "":
            self = .standard
        case Name.sessionTimeout1m:
            self = .sessionTimeout1m
        case Name.noScreenshots:
            self = .noScreenshots
        case Name.sdkDefaults:
            self = .sdkDefaults
        case let name?:
            self = .unknown(name)
        }
    }

    /// The text the Behaviour hub shows, for a test to read back.
    ///
    /// `Profile: <name>`, `Profile: default` when none was asked for, or
    /// `Profile: unknown <name>` when the name matched none.
    var statusText: String {
        switch self {
        case .standard: return "Profile: default"
        case .sessionTimeout1m: return "Profile: \(Name.sessionTimeout1m)"
        case .noScreenshots: return "Profile: \(Name.noScreenshots)"
        case .sdkDefaults: return "Profile: \(Name.sdkDefaults)"
        case .unknown(let name): return "Profile: unknown \(name)"
        }
    }

    /// The layout to start the SDK with.
    ///
    /// ``standard`` and an unknown name give ``ConnectConfig/Layout/loadFromBundle()``,
    /// the `ConnectConfig` default.
    var layout: ConnectConfig.Layout {
        switch self {
        case .standard, .sessionTimeout1m, .unknown:
            return .loadFromBundle()
        case .noScreenshots:
            return ConnectProfile.layoutWithoutScreenshots()
        case .sdkDefaults:
            return .basicAnalytics
        }
    }

    /// The advanced settings to start the SDK with.
    ///
    /// - Parameter sampleSettings: The settings the sample starts with when no
    ///   profile is asked for.
    /// - Returns: `sampleSettings` for ``standard``, ``noScreenshots`` and an
    ///   unknown name; with `SessionTimeout` set to 1 for ``sessionTimeout1m``;
    ///   empty for ``sdkDefaults``.
    func advanced(over sampleSettings: [ConnectConfig.AdvancedKey: Any]) -> [ConnectConfig.AdvancedKey: Any] {
        switch self {
        case .standard, .noScreenshots, .unknown:
            return sampleSettings
        case .sessionTimeout1m:
            // The SDK multiplies SessionTimeout by 60 000 ms, so the unit is minutes.
            return sampleSettings.merging([.sessionTimeout: 1]) { _, profile in profile }
        case .sdkDefaults:
            return [:]
        }
    }

    // MARK: - Private

    private enum Name {
        static let sessionTimeout1m = "session-timeout-1m"
        static let noScreenshots = "no-screenshots"
        static let sdkDefaults = "sdk-defaults"
    }

    /// The sample's own layout (its bundled `ConnectLayoutConfig.json`, with the
    /// masking rules) with screenshots turned off for every screen.
    private static func layoutWithoutScreenshots() -> ConnectConfig.Layout {
        let sampleLayout = ConnectConfig.Layout.loadFromBundle()
        var autoLayout = sampleLayout.autoLayout ?? [:]
        var globalSettings = autoLayout["GlobalScreenSettings"] as? [AnyHashable: Any] ?? [:]
        globalSettings["ScreenShot"] = false
        autoLayout["GlobalScreenSettings"] = globalSettings
        return ConnectConfig.Layout(autoLayout: autoLayout, appendMapIds: sampleLayout.appendMapIds)
    }
}
