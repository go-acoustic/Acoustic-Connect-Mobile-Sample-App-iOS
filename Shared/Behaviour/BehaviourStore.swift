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

    /// The result message from the most recent custom-event call, or `nil`
    /// before one has been made.
    @Published private(set) var customEventResult: String?

    // MARK: - Init

    private init() {}

    // MARK: - Custom events

    /// The event name the custom-event card sends. Matches the React Native
    /// sample so the same event can be found in any sample's posted message.
    static let customEventName = "demoCustomEvent"

    /// The custom-event payload.
    ///
    /// Deliberately mixes all three value types, because the unwrapping bug the
    /// matching verification scenario covers hit every type through the same
    /// path: a string must arrive as `pro`, not wrapped in its bridge type.
    static let customEventPayload: [String: Any] = [
        "tier": "pro",
        "isTrial": false,
        "seats": 2
    ]

    /// The payload as the cards print it, written out rather than serialised so
    /// the key order is stable across runs and platforms.
    static let customEventPayloadDisplay = """
        {
          "tier": "pro",
          "isTrial": false,
          "seats": 2
        }
        """

    /// Logs the custom event and records the outcome in ``customEventResult``.
    ///
    /// Read the result under `customEvent` in the message posted to the
    /// collector configured in `ConnectSDKManager`. iOS posts when the app is
    /// backgrounded.
    func logCustomEvent() {
        let success = ConnectCustomEvent.sharedInstance().logEvent(
            Self.customEventName,
            values: Self.customEventPayload,
            level: kConnectMonitoringLevelType.connectMonitoringLevelCellularAndWiFi
        )
        customEventResult = success
            ? "✓ queued \(Self.customEventName) — read customEvent in the posted message"
            : "✗ failed to queue \(Self.customEventName)"
    }
}
