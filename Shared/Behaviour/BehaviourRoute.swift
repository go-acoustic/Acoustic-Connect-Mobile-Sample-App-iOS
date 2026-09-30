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

/// The Behaviour tab's navigation stack.
///
/// ```
/// Behaviour (hub)
/// ├── Showcase ────── ShowcaseDetail (recursive, depth-capped)
/// ├── Verification ── WebViewPost
/// └── ScreenViews ─── Case
/// ```
///
/// The stack is load-bearing rather than cosmetic: screen-view logging only
/// fires on a real navigation, so several cards need somewhere to navigate to.
/// Mirrors `BehaviourStackParamList` in `screens/behaviourRoutes.ts`, so the
/// SwiftUI sample, the UIKit sample and React Native log the same screen names
/// in the same order.
///
/// The target shape is React Native's seven routes, and this type carries all
/// of them.
///
/// ## Example
/// ```swift
/// NavigationStack(path: $path) {
///     BehaviourHubView(path: $path)
///         .navigationDestination(for: BehaviourRoute.self) { route in
///             route.destination()
///         }
/// }
/// ```
enum BehaviourRoute: Hashable {

    /// The integration reference — one card per capture feature.
    case showcase

    /// The regression surface — one card per shipped fix.
    case verification

    /// A screen whose only job is to be arrived at, so a screen view is logged
    /// with `name` and the previous screen as referrer.
    ///
    /// - Parameters:
    ///   - name: The screen name to log.
    ///   - depth: How many detail screens deep this one is, starting at 1.
    case showcaseDetail(name: String, depth: Int)

    /// The WebView form-POST check, pushed from the Verification screen.
    ///
    /// Always present on iOS, unlike React Native, where the route is optional
    /// because not every host app carries `react-native-webview`.
    case webViewPost

    /// The screen-name test surface, pushed from the Verification screen.
    case screenViews

    /// One screen-name case, arrived at by navigation, so the screen view is
    /// logged from the route — the path a customer's app takes.
    ///
    /// - Parameter screenViewCase: The case whose name this screen logs. Only
    ///   navigation cases reach here, so its name is never `nil`.
    case screenViewCase(ScreenViewCase)

    /// How deep the detail chain may go.
    ///
    /// A few levels show the referrer chain advancing; an unbounded stack is
    /// only a way to run out of memory. Matches `MAX_DEPTH` in
    /// `ShowcaseDetailScreen.tsx`.
    static let maxShowcaseDepth = 5

    /// The screen name logged on arrival.
    ///
    /// iOS derives a screen name from the view controller's class unless one is
    /// supplied, so every screen in this stack logs its name explicitly. The
    /// values match what React Native's `<Connect>` reads from `params.name`,
    /// falling back to the route name — note `WebViewPost`, which seeds no
    /// param and so logs its route name unspaced.
    var screenName: String {
        switch self {
        case .showcase: return "Showcase"
        case .verification: return "Verification"
        case .showcaseDetail(let name, _): return name
        case .webViewPost: return "WebViewPost"
        case .screenViews: return "Screen Views"
        case .screenViewCase(let screenViewCase): return screenViewCase.name ?? ""
        }
    }

    /// The navigation-bar title.
    var title: String {
        switch self {
        case .showcase: return "Showcase"
        case .verification: return "Verification"
        case .showcaseDetail(let name, _): return name
        case .webViewPost: return "WebView POST"
        case .screenViews: return "Screen Views"
        // The case label, never the logged name: a 300-character or emoji name
        // would make the header unreadable, and the screen body prints it anyway.
        case .screenViewCase(let screenViewCase): return screenViewCase.label
        }
    }

    /// The screen name of the Behaviour tab's root, logged when the hub appears.
    static let hubScreenName = "Behaviour"

    /// The screen name logged for the replay modal.
    ///
    /// The modal is presented rather than pushed, so it is not a route, but iOS
    /// still logs a screen view for the controller that presents it, and would
    /// name that one after its class.
    static let replayModalScreenName = "Replay modal"
}
