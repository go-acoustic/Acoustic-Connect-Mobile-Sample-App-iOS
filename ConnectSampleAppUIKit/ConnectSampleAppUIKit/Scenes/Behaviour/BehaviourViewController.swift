//
// Copyright (C) 2026 Acoustic, L.P. All rights reserved.
//
// Licensed under the Acoustic License (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy
// at https://www.acoustic.com/licenses/acoustic-license
//
// Sample app provided "as is", without warranty of any kind.
//

import UIKit

/// Behaviour tab root — a hub with two entry points into the analytics half of
/// the SDK, matching the SwiftUI sample's `BehaviourDemoView`.
///
/// - **Showcase** is the general-purpose demo: one card per capture feature.
/// - **Verification** is the release-verification surface: one card per shipped
///   fix.
///
/// Both are pushed onto this tab's navigation controller, because screen-view
/// logging only fires on a real navigation — and on UIKit each push produces a
/// distinct view controller, which is the behaviour this sample exists to
/// exercise.
@MainActor
final class BehaviourViewController: CardListViewController {

    override var screenName: String? { BehaviourRoute.hubScreenName }

    override func viewDidLoad() {
        super.viewDidLoad()
        setCards([showcaseCard(), verificationCard(), footnoteCard()])
    }

    // MARK: - Cards

    private func showcaseCard() -> CardView {
        let button = makePrimaryButton(
            title: "Open Showcase",
            identifier: SampleID.Behaviour.openShowcase,
            action: UIAction { [weak self] _ in
                self?.push(ShowcaseViewController(), as: .showcase)
            }
        )

        return CardView(
            title: "Showcase",
            arrangedSubviews: [
                makeBodyLabel("""
                    What the SDK captures once it is enabled: screen views, taps, \
                    text entry, custom events, signals, dialogs, exceptions and \
                    session replay of modals. One card per feature, each with the \
                    call it makes and where to read the result.
                    """),
                button
            ]
        )
    }

    private func verificationCard() -> CardView {
        let button = makeSecondaryButton(
            title: "Open Verification",
            identifier: SampleID.Behaviour.openVerification,
            action: UIAction { [weak self] _ in
                self?.push(VerificationViewController(), as: .verification)
            }
        )

        return CardView(
            title: "Verification",
            arrangedSubviews: [
                makeBodyLabel("""
                    Release-verification checks. Each card verifies one shipped fix \
                    against the SDK build this app is running, with the steps to \
                    follow and the payload to expect. Intended for regression runs \
                    rather than as an integration reference.
                    """),
                button
            ]
        )
    }

    private func footnoteCard() -> CardView {
        CardView(
            title: "Reading the results",
            arrangedSubviews: [
                makeBodyLabel("""
                    Both screens post to the collector configured in \
                    ConnectSDKManager. iOS posts when the app is backgrounded, so \
                    background the app and read the messages there.
                    """, style: .caption1)
            ]
        )
    }

    // MARK: - Navigation

    /// Pushes a screen and titles it from its route, so a route's title and the
    /// name it logs cannot drift apart.
    ///
    /// - Parameters:
    ///   - viewController: The screen to push.
    ///   - route: The route it represents.
    private func push(_ viewController: UIViewController, as route: BehaviourRoute) {
        viewController.title = route.title
        navigationController?.pushViewController(viewController, animated: true)
    }
}
