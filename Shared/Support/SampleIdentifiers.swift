//
// Copyright (C) 2026 Acoustic, L.P. All rights reserved.
//
// Licensed under the Acoustic License (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy
// at https://www.acoustic.com/licenses/acoustic-license
//
// Sample app provided "as is", without warranty of any kind.
//

import Foundation

/// Accessibility identifiers for the sample apps' UI contract.
///
/// Every string here is the React Native sample's `testID` verbatim, so one
/// page-object set in the shared end-to-end suite drives the SwiftUI sample,
/// the UIKit sample and React Native from the same locators. Extracted
/// from `Examples/shared` in `react-native-acoustic-connect-beta`, not recalled
/// — change a value here only when the React Native sample changes.
///
/// Both iOS samples read from this one type so they cannot drift from each
/// other, and the file doubles as the reviewable list of what the contract
/// covers.
///
/// The whole contract is declared here at once, ahead of the screens that use
/// it, so it can be diffed against the React Native sample in one place. Groups
/// marked **Reserved** have no consuming view yet and arrive with the screens
/// that consume them; nothing else distinguishes them, and their values are as
/// settled as the rest.
///
/// In the SwiftUI sample, controls take their identifier through
/// `.connectIdentifier(_:)`: it sets the accessibility identifier and also makes
/// the control identifiable in session replay, which a plain
/// `.accessibilityIdentifier(_:)` cannot do for a SwiftUI view.
///
/// ## Example
/// ```swift
/// Button("Open Showcase") { }
///     .connectIdentifier(SampleID.Behaviour.openShowcase)
/// ```
enum SampleID {

    /// Tab-bar buttons. React Native sets these with `tabBarButtonTestID` in
    /// `Examples/bare-workflow/src/navigation/RootNavigator.tsx`. The UIKit
    /// sample carries no Push tab, so it uses only the last two.
    enum Tab {
        static let push = "tab_notification"
        static let identity = "tab_identity"
        static let behaviour = "tab_behaviour"
    }

    /// Identity tab. The React Native sample's Push screen sets no identifiers
    /// of its own, so ``Tab/push`` is the whole Push contract.
    enum Identity {
        static let identifierName = "et_identifier_name"
        static let identifierValue = "et_identifier_value"
        static let sendIdentitySignal = "btn_send_identity_signal"
        static let sendAccountRegisteredSignal = "btn_send_account_registered_signal"
    }

    /// Behaviour hub — the two entry points into the Behaviour stack.
    enum Behaviour {
        static let openShowcase = "btn_open_showcase"
        static let openVerification = "btn_open_verification"
    }

    /// Showcase screen and its recursive detail screen.
    enum Showcase {
        static let openDetail = "btn_showcase_open_detail"
        static let tap = "btn_showcase_tap"
        static let tapCount = "txt_showcase_taps"
        static let note = "field_showcase_note"
        static let secret = "field_showcase_secret"
        static let sendCustomEvent = "btn_send_custom_event"
        static let customEventResult = "txt_custom_event_result"
        static let sendNestedSignal = "btn_send_nested_signal"
        static let sendFlatSignal = "btn_send_flat_signal"
        static let signalResult = "txt_signal_result"
        static let exception = "btn_showcase_exception"
        static let exceptionResult = "txt_showcase_exception_result"
        static let dialog = "btn_showcase_dialog"
        static let dialogResult = "txt_showcase_dialog_result"
        static let captureDisable = "btn_capture_disable"
        static let captureEnable = "btn_capture_enable"
        static let captureState = "txt_capture_state"
        static let pushDetail = "btn_showcase_push_detail"
        static let back = "btn_showcase_back"
    }

    /// **Reserved.** Verification screen — the cards unique to it, which arrive
    /// with those cards. The custom-event, signal, replay-modal and
    /// capture-control cards are shared with Showcase and keep the identifiers
    /// declared under ``Showcase`` and ``ReplayModal``.
    enum Verification {
        static let identityDefaulted = "btn_identity_defaulted"
        static let identityExplicit = "btn_identity_explicit"
        static let identityDefaultsResult = "txt_identity_defaults_result"
        static let maskedField = "field_masked"
        static let accessibilityImplicit = "a11y_implicit"
        static let accessibilityExplicit = "a11y_explicit"
        static let accessibilityValue = "a11y_value"
        static let accessibilityField = "a11y_field"
    }

    /// Replay-modal controls. The opaque card is on Showcase;
    /// ``openTransparent`` is **Reserved** for the transparent card, which
    /// arrives with the Verification screen.
    ///
    /// React Native's `components/ReplayModalCard.tsx` carries no `testID` at
    /// all, so these names originate here rather than being mirrored. They are
    /// a proposal for the shared end-to-end suite to adopt across all three
    /// samples. If that suite settles on different names, change them here and
    /// in React Native rather than letting the same control carry three names.
    ///
    /// ``result`` is the status line that echoes the note and the action count,
    /// and the modal's note field and action button are named too, so nothing
    /// inside the modal has to be found by position.
    enum ReplayModal {
        static let openOpaque = "btn_open_replay_modal_opaque"
        static let openTransparent = "btn_open_replay_modal_transparent"
        static let note = "field_replay_modal_note"
        static let action = "btn_replay_modal_action"
        static let close = "btn_close_replay_modal"
        static let result = "txt_replay_modal_result"
    }

    /// **Reserved.** WebView POST screen, which arrives with that screen.
    ///
    /// React Native also declares `txt_webview_unavailable`, shown when the
    /// navigator has no `WebViewPost` route because the Expo sample carries no
    /// `react-native-webview`. `WKWebView` is always available on iOS, so that
    /// placeholder can never render here and is deliberately omitted.
    enum WebView {
        static let open = "btn_open_webview_post"
        static let submit = "btn_webview_submit"
        static let capture = "btn_webview_capture"
        static let reset = "btn_webview_reset"
        static let webView = "webview_post"
    }

    /// **Reserved.** Screen-views screen and the per-case screen it navigates
    /// to, which arrive with those screens alongside ``ScreenViewCases``.
    enum ScreenViews {
        static let open = "btn_open_screen_views"
        static let sendAll = "btn_screenview_send_all"
        static let result = "txt_screenview_result"
        static let caseRelog = "btn_case_relog"
        static let caseRelogResult = "txt_case_relog_result"
        static let casePushNext = "btn_case_push_next"

        /// Logs a case's name directly, through `logScreenViewContext`.
        ///
        /// - Parameter caseID: The ``ScreenViewCase/id`` of the case.
        /// - Returns: The identifier for that case's direct-log button.
        static func directButton(_ caseID: String) -> String {
            "btn_screenview_\(caseID)"
        }

        /// Navigates to a case's screen, so the screen view is logged from the
        /// route rather than by an explicit call.
        ///
        /// - Parameter caseID: The ``ScreenViewCase/id`` of the case.
        /// - Returns: The identifier for that case's navigation button.
        static func navigateButton(_ caseID: String) -> String {
            "btn_navigate_\(caseID)"
        }
    }

    /// Suffixes React Native's `DemoTextField` adds around a field's own
    /// identifier, mirrored so a page object can address the same three
    /// elements on every platform.
    enum FieldPart {
        /// - Parameter identifier: The field's identifier.
        /// - Returns: The identifier of the view wrapping label and field.
        static func container(_ identifier: String) -> String {
            "\(identifier)_container"
        }

        /// - Parameter identifier: The field's identifier.
        /// - Returns: The identifier of the caption above the field.
        static func label(_ identifier: String) -> String {
            "\(identifier)_label"
        }
    }
}
