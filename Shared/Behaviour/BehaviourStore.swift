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
/// explicit calls: custom events, signals, handled exceptions, identity
/// defaults, direct screen views and runtime capture control.
@MainActor
final class BehaviourStore: ObservableObject {

    // MARK: - Shared instance

    static let shared = BehaviourStore()

    // MARK: - Observable state

    /// The result message from the most recent custom-event call, or `nil`
    /// before one has been made.
    @Published private(set) var customEventResult: String?

    /// The result message from the most recent signal call, or `nil` before
    /// one has been made.
    @Published private(set) var signalResult: String?

    /// The result message from the most recent handled-exception report, or
    /// `nil` before one has been made.
    @Published private(set) var exceptionResult: String?

    /// What the most recent capture-control call did, or `nil` before one has
    /// been made.
    @Published private(set) var captureState: String?

    /// The result message from the most recent identity-defaults call, or
    /// `nil` before one has been made.
    @Published private(set) var identityDefaultsResult: String?

    /// The most recent direct screen-view sends, newest first, at most
    /// ``screenViewLogLimit``.
    @Published private(set) var screenViewLog: [ScreenViewLogEntry] = []

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

    // MARK: - Signals

    /// A signal as the signal card sends it.
    enum Signal {

        /// An object and an array of objects, plus a number and a null one
        /// level down — the shape that has to survive serialisation intact.
        case nested

        /// Scalars only, the shape existing callers send.
        case flat

        /// The label the result line starts with.
        var label: String {
            switch self {
            case .nested: return "nested"
            case .flat: return "flat"
            }
        }

        /// The payload handed to `logSignal`.
        ///
        /// Identical to `NESTED_PAYLOAD` / `FLAT_PAYLOAD` in the React Native
        /// sample's `NestedSignalCard.tsx`, so the `signal` block in the posted
        /// type-21 message can be compared across samples. `NSNull` is how a
        /// JSON `null` is expressed in a Foundation dictionary.
        var payload: [String: Any] {
            switch self {
            case .nested:
                return [
                    "signalContent": [
                        "signalType": "pageview",
                        "url": "https://app.example.com/behaviour-demo",
                        "pageCategory": "behaviour-demo"
                    ],
                    "audience": [
                        ["name": "Account Name", "value": "Acme Corp"],
                        ["name": "Account ID", "value": "4815162342"]
                    ],
                    "cart": ["items": 3, "total": 24.99, "coupon": NSNull()]
                ]
            case .flat:
                return [
                    "signalType": "pageview",
                    "pageCategory": "behaviour-demo"
                ]
            }
        }

        /// The payload as the result line prints it — React Native's
        /// `JSON.stringify` output, written out because a Foundation
        /// dictionary has no key order to serialise from.
        var payloadDisplay: String {
            switch self {
            case .nested:
                return #"{"signalContent":{"signalType":"pageview","url":"https://app.example.com/behaviour-demo","pageCategory":"behaviour-demo"},"audience":[{"name":"Account Name","value":"Acme Corp"},{"name":"Account ID","value":"4815162342"}],"cart":{"items":3,"total":24.99,"coupon":null}}"#
            case .flat:
                return #"{"signalType":"pageview","pageCategory":"behaviour-demo"}"#
            }
        }
    }

    /// Logs `signal` and records the outcome in ``signalResult``.
    ///
    /// A `✓` means the SDK accepted the signal for posting, not that it was
    /// delivered. Read it under `signal` in the type-21 message posted to the
    /// collector.
    ///
    /// - Parameter signal: Which payload to send.
    func logSignal(_ signal: Signal) {
        let queued = ConnectCustomEvent.sharedInstance().logSignal(
            signal.payload,
            level: kConnectMonitoringLevelType.connectMonitoringLevelCellularAndWiFi
        )
        signalResult = "\(queued ? "✓" : "✗") \(signal.label) — \(signal.payloadDisplay)"
    }

    // MARK: - Exceptions

    /// An error the app catches and recovers from — invisible to the SDK
    /// unless the app reports it. The message matches the React Native
    /// sample's `ExceptionCard.tsx`.
    private struct ShowcaseError: LocalizedError {
        var errorDescription: String? { "Showcase: handled exception" }
    }

    /// Throws an error, catches it, and reports it with `unhandled` set to
    /// `false`, recording the outcome in ``exceptionResult``.
    ///
    /// A Swift `Error` is not an `NSException`, so reporting one means wrapping
    /// it: the error's type becomes the exception name and its description the
    /// reason. Crashes and uncaught exceptions are reported by the SDK on its
    /// own; this is the case it cannot see.
    func logHandledException() {
        do {
            throw ShowcaseError()
        } catch {
            let exception = NSException(
                name: NSExceptionName(String(describing: type(of: error))),
                reason: error.localizedDescription
            )
            let queued = ConnectCustomEvent.sharedInstance().logNSExceptionEvent(
                exception,
                dataDictionary: [:],
                isUnhandled: false
            )
            exceptionResult = "\(queued ? "✓" : "✗") queued exception \"\(error.localizedDescription)\""
        }
    }

    // MARK: - Identity defaults

    /// Logs an identity with both optional arguments omitted, so the SDK
    /// supplies its own defaults, and records the outcome in
    /// ``identityDefaultsResult``.
    ///
    /// The native API defaults `signalType` to `pageView` and adds no
    /// parameters. React Native's bridge defaults differently — `loggedIn`
    /// paired with `loginMethod` — which is the fix its matching scenario
    /// covers; that bridge is not in this app, so the native defaults are what
    /// the collector should receive here.
    func logIdentityDefaulted() {
        let queued = ConnectSDK.shared.identity.log(
            identifierName: "Email",
            identifierValue: "defaults@example.com"
        )
        identityDefaultsResult = "\(queued ? "✓" : "✗") defaulted — expect signalType: pageView"
    }

    /// Logs an explicit `accountRegistered` identity with its
    /// `registrationMethod`, the contrast case for ``logIdentityDefaulted()``,
    /// and records the outcome in ``identityDefaultsResult``.
    func logIdentityExplicit() {
        let queued = ConnectSDK.shared.identity.log(
            identifierName: "Email",
            identifierValue: "explicit@example.com",
            signalType: "accountRegistered",
            additionalParameters: ["registrationMethod": "email"]
        )
        identityDefaultsResult = "\(queued ? "✓" : "✗") explicit — expect registrationMethod: email"
    }

    // MARK: - Screen views

    /// One direct screen-view send, as the exact-name card lists it.
    struct ScreenViewLogEntry: Identifiable, Hashable {
        let id = UUID()

        /// The case sent.
        let caseID: String

        /// Whether the SDK accepted the message for the queue.
        let queued: Bool

        /// The name as ``ScreenViewCases/describe(_:)`` prints it.
        let shown: String

        /// The line the card prints.
        var line: String { "\(queued ? "✓" : "✗") \(caseID) → \(shown)" }
    }

    /// How many sends the exact-name card keeps.
    static let screenViewLogLimit = 12

    /// The referrer the exact-name card sends, matching React Native's
    /// `DirectScreenViewCard.tsx`.
    static let directScreenViewReferrer = "Screen View Diagnostics"

    /// The class the direct call reports. React Native's bridge sends
    /// `ReactNative_<name>`; these apps name the screen that sends it.
    static let directScreenViewClass = "ScreenViews"

    /// Logs a type-2 LOAD whose name is exactly `name`, bypassing navigation.
    ///
    /// Navigation cannot carry an empty or `nil` name — those two cases are
    /// only reachable this way.
    ///
    /// - Parameters:
    ///   - name: The logical page name, sent as is. `nil` is deliberate for the
    ///     null case.
    ///   - referrer: The referrer to send.
    /// - Returns: Whether the SDK accepted the message for the queue — not that
    ///   the collector received it.
    @discardableResult
    func logScreenViewDirect(name: String?, referrer: String) -> Bool {
        ConnectCustomEvent.sharedInstance().logScreenViewContext(
            name,
            withClass: Self.directScreenViewClass,
            applicationContext: .load,
            referrer: referrer
        )
    }

    /// Sends one case through the direct call and records it in
    /// ``screenViewLog``.
    ///
    /// - Parameter screenViewCase: The case to send.
    func logScreenViewDirect(_ screenViewCase: ScreenViewCase) {
        let queued = logScreenViewDirect(name: screenViewCase.name, referrer: Self.directScreenViewReferrer)
        let entry = ScreenViewLogEntry(
            caseID: screenViewCase.id,
            queued: queued,
            shown: ScreenViewCases.describe(screenViewCase.name)
        )
        screenViewLog = Array(([entry] + screenViewLog).prefix(Self.screenViewLogLimit))
    }

    /// Sends every direct case, in table order.
    func logAllScreenViewsDirect() {
        ScreenViewCases.direct.forEach(logScreenViewDirect(_:))
    }

    // MARK: - Capture control

    /// Disables the SDK and records the resulting state in ``captureState``.
    ///
    /// Capture should stop until ``enableCapture()``: navigate a few screens,
    /// re-enable, and check that nothing from the disabled stretch reaches the
    /// collector, including in the posts that follow re-enabling.
    func disableCapture() {
        ConnectSDK.shared.disable()
        captureState = """
            disable() — isEnabled is \(ConnectSDK.shared.isEnabled); \
            now navigate and check for further layout captures
            """
    }

    /// Enables the SDK again the way the sample first started it, and records
    /// the resulting state in ``captureState``.
    func enableCapture() {
        ConnectSDKManager.shared.reenable()
        captureState = "enable() — isEnabled is \(ConnectSDK.shared.isEnabled)"
    }
}
