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

/// How a fix reaches the app. The channels ship on different cadences, which is
/// what makes ``Scenario/blockedBy`` necessary.
enum ScenarioChannel: String {
    /// TypeScript, or the Kotlin/Swift bridge in the React Native package.
    /// Ships with the npm release, so it is present as soon as the app resolves
    /// that version.
    case reactNative

    /// The Connect iOS artifact. Only present once a build containing the
    /// commit is published, which lags the source fix.
    case iOSNative

    /// The Connect Android artifact. Same lag.
    case androidNative

    /// Both native SDKs at once, each with its own lag, so one platform can be
    /// verifiable while the other is still a baseline.
    case native

    /// Proven by the app building and running at all, with nothing to tap.
    case build

    /// The label shown on the card.
    var label: String {
        switch self {
        case .reactNative: return "React Native SDK"
        case .iOSNative: return "iOS native SDK"
        case .androidNative: return "Android native SDK"
        case .native: return "iOS + Android native SDK"
        case .build: return "Build-time"
        }
    }
}

/// Which platform a fix applies to. Cards render on both samples regardless, so
/// a tester can see what the other platform is expected to do.
enum ScenarioPlatform: String {
    case iOS = "ios"
    case android = "android"
    case both = "both"
}

/// One shipped fix this harness verifies, and whether it is actually verifiable
/// against the SDK build the app is running.
///
/// Mirrors `verification/scenarios.ts` in the React Native sample. Keys,
/// titles, channels, platforms and order are React Native's verbatim, so the
/// end-to-end suite reads the same registry on every sample. The `action`,
/// `expected` and `blockedBy` text differs only where React Native's would be
/// untrue for these apps — they run the native SDK, not the bridge — and
/// each such passage says what the native SDK does instead.
struct Scenario: Identifiable, Hashable {

    /// Stable, descriptive id — safe to quote in a support thread.
    let key: String

    var id: String { key }

    let title: String

    /// What the tester does.
    let action: String

    /// What a fixed build produces.
    let expected: String

    let channel: ScenarioChannel

    let platform: ScenarioPlatform

    /// Set when the fix exists in source but no published artifact carries it
    /// yet.
    ///
    /// Such a card still renders, deliberately: running it captures the
    /// *failing* baseline, which is what makes the later re-run meaningful.
    /// Reading a blocked card as a pass is the trap this field exists to
    /// prevent, so the card must say so rather than hiding itself.
    let blockedBy: String?

    init(
        key: String,
        title: String,
        action: String,
        expected: String,
        channel: ScenarioChannel,
        platform: ScenarioPlatform,
        blockedBy: String? = nil
    ) {
        self.key = key
        self.title = title
        self.action = action
        self.expected = expected
        self.channel = channel
        self.platform = platform
        self.blockedBy = blockedBy
    }
}

/// The registry of verification scenarios, in render order.
enum Scenarios {

    static let customEventValueTypes = Scenario(
        key: "custom-event-value-types",
        title: "Custom-event values keep their type",
        action: "Send a custom event carrying a string, a boolean and a number.",
        expected: """
            Values arrive unwrapped — "pro", "true", "2.0" — not the Kotlin \
            data-class form "Second(value=pro)". Android was the broken \
            platform; iOS already unwrapped correctly, so the two should now \
            agree.
            """,
        channel: .reactNative,
        platform: .both
    )

    static let signalNestedJSON = Scenario(
        key: "signal-nested-json",
        title: "logSignal accepts nested JSON",
        action: "Send the nested signal payload (object + array of objects).",
        expected: """
            Nesting survives to the collector on both platforms. The payload \
            keeps its numbers one level down, which is portable across every \
            supported Connect Android version; a top-level number needs \
            Connect Android 11.0.24-beta or newer, having been dropped by the \
            SDK serializer before that.
            """,
        channel: .reactNative,
        platform: .both
    )

    static let identityLoginMethodDefault = Scenario(
        key: "identity-login-method-default",
        title: "loggedIn defaults to loginMethod",
        action: """
            Log an identity with both the signal type and the parameters \
            omitted, so the SDK — the bridge, on React Native — has to supply \
            its own defaults.
            """,
        expected: """
            On React Native the defaulted signal carries loginMethod: email. \
            Before the fix the bridge paired its loggedIn default with \
            registrationMethod, so every defaulted identity call emitted the \
            wrong attribute. This app has no bridge: the native SDK defaults to \
            signalType pageView with no method, and that is what it posts. The \
            explicit accountRegistered call carries registrationMethod: email \
            everywhere.
            """,
        channel: .reactNative,
        platform: .both
    )

    static let layoutConfigApplied = Scenario(
        key: "layout-config-applied",
        title: "Layout config from ConnectConfig.json is applied",
        action: """
            Type into the masked field below, then read the value in the \
            posted layout message.
            """,
        expected: """
            The value arrives masked. In this app the rules live in \
            ConnectLayoutConfig.json in the app bundle, which only \
            enable(with:) reads — enable(appKey:postURL:) ignores it. React \
            Native reads them from the layoutConfigIos / layoutConfigAndroid \
            block of ConnectConfig.json; its bridge used to look for a plain \
            "layoutConfig" key and so applied nothing at all.
            """,
        channel: .reactNative,
        platform: .both
    )

    static let androidCompileClasspath = Scenario(
        key: "android-compile-classpath",
        title: "eocore/tealeaf on the Android compile classpath",
        action: """
            Nothing to tap — this one is proven by the app building and \
            running at all.
            """,
        expected: """
            The Android module compiles against com.ibm.eo / com.tl types. \
            Connect marks them runtime-scope in its POM, so they need \
            compileOnly + testCompileOnly entries to be visible at compile \
            time.
            """,
        channel: .build,
        platform: .android
    )

    static let replayCapturesModal = Scenario(
        key: "replay-captures-modal",
        title: "Session replay captures React Native <Modal>",
        action: "Open each modal, interact, and close it.",
        expected: """
            The replay carries a populated control tree for the modal, not an \
            empty one. A React Native <Modal> presents outside the navigator \
            hierarchy, which is why it took a separate capture path. The \
            modals in this app are native presentations, which need Connect \
            iOS 2.1.38 or newer: each should log its own screen view and a \
            layout carrying its controls, where older builds dropped a view \
            controller declared private or nested — as these are.
            """,
        channel: .iOSNative,
        platform: .iOS
    )

    static let screenViewReferrer = Scenario(
        key: "screenview-referrer",
        title: "Screenview referrer points at the previous screen",
        action: """
            Move between screens in Screen Views and read the referrer on each \
            screenview.
            """,
        expected: """
            referrer is the screen you came from. The iOS bug set it to the \
            screen's own name on every event, which collapses a whole session \
            into one replay step. Android already chained it correctly. A \
            screen named with setCurrentScreen(pageName:) needs Connect iOS \
            2.1.37 or newer, where that name is the screenview's name; older \
            builds posted it as the referrer instead.
            """,
        channel: .iOSNative,
        platform: .iOS
    )

    static let webViewPostNotReplayedAsGet = Scenario(
        key: "webview-post-not-replayed-as-get",
        title: "WebView form POST is not replayed as GET",
        action: "Submit the form in the WebView screen.",
        expected: """
            The endpoint answers 200 and echoes the submitted form. It only \
            answers POST, so a request replayed as a GET would come back 405 \
            Method Not Allowed instead — which is how a payment submission \
            failed when the capture reload re-issued the current URL as a GET.
            """,
        channel: .androidNative,
        platform: .android,
        blockedBy: """
            This harness does not reproduce the 405, and the shipped SDK test \
            explains why: WebView never calls shouldOverrideUrlLoading for a \
            main-frame form POST, so a normal submission cannot trigger the \
            conversion — the fix's own test drives the hazard directly \
            instead. What this harness DID establish: setting \
            GoogleWebViewEnabled false suppresses WebView instrumentation \
            completely (Found Webview 11 -> 0, RNCWebView nodes 3 -> 0, with \
            the screen demonstrably visited), which is the customer's missing \
            workaround. On connect 11.0.18-beta — which does NOT carry the fix \
            — the POST survives identically, with WebView capture demonstrably \
            engaged (capture JS injected, RNCWebView nodes in the layout) and \
            after an explicit logScreenLayout on the POST result. So a pass \
            here says nothing about the fix. Two earlier leads here have since \
            been measured and can be dropped: WebView discovery does work on \
            this screen (Found Webview fires and RNCWebView nodes appear in \
            the layout) once the WebView is scrolled into the viewport — the \
            zero-hit readings came from capturing while it sat below the fold, \
            which the tree-walk skips by design. What remains real is that the \
            SDK logs "WebView Id is: null" for an RN-hosted WebView, so \
            the DOM-capture DCID it waits for can never be matched, and a \
            capture that does find the WebView currently drops the screen's \
            whole layout message. That is a native-SDK defect, tracked \
            separately.
            """
    )

    static let accessibilityLabelMasking = Scenario(
        key: "accessibility-label-masking",
        title: "Masking covers the accessibility label and hint",
        action: """
            Drive a capture on the card below, then read the `accessibility` \
            object of each row in the posted layout message.
            """,
        expected: """
            No row carries the address in `accessibility.label`. Masking used \
            to redact an element's value only and serialise the accessibility \
            object verbatim, so on React Native — where a <Text> node's label \
            defaults to its own content — a masked address still travelled in \
            the label. `accessibility.id` is still present and unredacted, \
            deliberately: it identifies the element rather than describing it. \
            Needs Connect iOS 2.1.22+ or Android 11.0.23-beta+; against an \
            older SDK this records the failing baseline instead. In the \
            SwiftUI sample the rows carry their accessibility.id only from \
            Connect iOS 2.1.41. The email rule that masks these rows is in \
            ConnectLayoutConfig.json — without it nothing here is masked and \
            every row reads as a leak.
            """,
        channel: .native,
        platform: .both
    )

    /// Every scenario, in the order the Verification screen renders them.
    ///
    /// Nothing is filtered by platform: an Android-only card still renders on
    /// iOS so a tester can see what the other platform is expected to do, which
    /// is how the React Native sample behaves.
    static let all: [Scenario] = [
        customEventValueTypes,
        signalNestedJSON,
        identityLoginMethodDefault,
        layoutConfigApplied,
        androidCompileClasspath,
        replayCapturesModal,
        screenViewReferrer,
        webViewPostNotReplayedAsGet,
        accessibilityLabelMasking
    ]
}
