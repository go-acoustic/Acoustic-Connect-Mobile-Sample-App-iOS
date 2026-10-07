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

/// Verification screen — one card per shipped fix, for regression runs rather
/// than as an integration reference.
///
/// Composed card by card in the React Native sample's order
/// (`VerificationScreen.tsx`), not by walking the scenario registry: the
/// signal, capture-control and modal cards appear as the same plain cards the
/// Showcase shows, and only the cards unique to this screen sit in a scenario
/// frame. Matches `VerificationView` in the SwiftUI sample.
///
/// Nothing is filtered by platform: an Android-only card still renders here so a
/// tester can see what the other platform is expected to do, which is how the
/// React Native sample behaves.
///
/// Cards whose body is also a Showcase demo share that body rather than
/// duplicating it — the body is the demo, the frame is per screen.
@MainActor
final class VerificationViewController: CardListViewController {

    override var screenName: String? { BehaviourRoute.verification.screenName }

    override func viewDidLoad() {
        super.viewDidLoad()
        setCards([
            howToReadCard(),
            makeScenarioCard(
                scenario: Scenarios.screenViewReferrer,
                body: [
                    makeSecondaryButton(
                        title: "Open Screen Views",
                        identifier: SampleID.ScreenViews.open,
                        action: UIAction { [weak self] _ in self?.pushScreenViews() }
                    )
                ]
            ),
            makeScenarioCard(scenario: Scenarios.customEventValueTypes, body: [CustomEventBodyView()]),
            SignalCardBody.makeCard(),
            IdentityDefaultsCardBody.makeCard(),
            MaskedFieldCardBody.makeCard(),
            AccessibilityMaskCardBody.makeCard(),
            CaptureControlCardBody.makeCard(),
            webViewCard(),
            makeScenarioCard(
                scenario: Scenarios.replayCapturesModal,
                body: [makeBodyLabel("""
                    The two modal cards below present outside the navigation stack — \
                    one opaque full screen, one transparent over the screen beneath — \
                    the case that produced an empty control tree.
                    """)]
            ),
            ReplayModalCardBody.makeCard(presenter: self),
            ReplayModalCardBody.makeCard(presenter: self, transparent: true),
            makeScenarioCard(scenario: Scenarios.androidCompileClasspath, body: [buildVerifiedNote()])
        ])
    }

    // MARK: - Cards

    private func howToReadCard() -> CardView {
        CardView(
            title: "How to read these cards",
            arrangedSubviews: [
                makeBodyLabel("""
                    Each card names one fix, what to do, and what a fixed build \
                    produces. Drive the card, background the app so iOS posts, then \
                    read the message at the collector configured in \
                    ConnectSDKManager.
                    """),
                makeBodyLabel("""
                    A card marked "Baseline only" has no published artifact carrying \
                    its fix. It still runs, deliberately — the failing result is the \
                    baseline that makes a later re-run meaningful. Do not read it as \
                    a pass.
                    """)
            ]
        )
    }

    private func webViewCard() -> CardView {
        makeScenarioCard(
            scenario: Scenarios.webViewPostNotReplayedAsGet,
            body: [
                makeSecondaryButton(
                    title: "Open WebView form POST",
                    identifier: SampleID.WebView.open,
                    action: UIAction { [weak self] _ in
                        self?.pushWebViewPost()
                    }
                )
            ]
        )
    }

    /// The build-time scenario's note, on a green rule: there is nothing to tap.
    private func buildVerifiedNote() -> UIView {
        let note = makeBodyLabel("""
            Verified by the Android sample building at all — a broken compile \
            classpath fails the Android build outright.
            """, style: .caption1)
        note.textColor = UIColor(named: "violet")

        let rule = UIView()
        rule.backgroundColor = UIColor(named: "acousticGreen")
        rule.widthAnchor.constraint(equalToConstant: 3).isActive = true

        let row = UIStackView(arrangedSubviews: [rule, note])
        row.axis = .horizontal
        row.spacing = 10
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 10)
        row.backgroundColor = UIColor(named: "lightGrey")
        row.layer.cornerRadius = 8
        row.clipsToBounds = true
        return row
    }

    // MARK: - Navigation

    private func pushScreenViews() {
        let screen = ScreenViewsViewController()
        screen.title = BehaviourRoute.screenViews.title
        navigationController?.pushViewController(screen, animated: true)
    }

    private func pushWebViewPost() {
        let screen = WebViewPostViewController()
        screen.title = BehaviourRoute.webViewPost.title
        navigationController?.pushViewController(screen, animated: true)
    }
}
