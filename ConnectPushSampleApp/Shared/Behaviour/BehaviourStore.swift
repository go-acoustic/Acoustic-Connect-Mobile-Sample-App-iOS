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
import Combine
import Foundation

/// Behaviour capture for the sample apps.
///
/// Holds no UI, so both the SwiftUI sample and the UIKit sample drive the same
/// code — SwiftUI observes it directly, UIKit subscribes to the publishers.
///
/// Most of what the SDK captures needs no call at all: screen views, taps and
/// text entry are captured once the SDK is enabled. This type covers the
/// explicit logging calls, starting with custom events.
@MainActor
final class BehaviourStore: ObservableObject {

    // MARK: - Shared instance

    static let shared = BehaviourStore()

    // MARK: - Observable state

    /// The result message from the most recent behaviour log call.
    @Published private(set) var lastResult: String?

    // MARK: - Init

    private init() {}

    // MARK: - Custom events

    /// Logs a custom event with a flat map of values.
    ///
    /// Read the result under `customEvent` in the message posted to the collector
    /// configured in ``ConnectSDKManager``. iOS posts when the app is backgrounded.
    ///
    /// - Parameters:
    ///   - name: The event name, as it appears in the posted JSON.
    ///   - values: Key/value pairs logged alongside the event.
    func logCustomEvent(
        name: String = "sample_custom_event",
        values: [String: Any] = ["source": "sample-app", "tier": "pro", "score": 2.0, "active": true]
    ) {
        let success = ConnectCustomEvent.sharedInstance().logEvent(name, values: values)
        lastResult = success
            ? "✓ Logged custom event \(name)"
            : "✗ Failed to log custom event \(name)"
    }
}
