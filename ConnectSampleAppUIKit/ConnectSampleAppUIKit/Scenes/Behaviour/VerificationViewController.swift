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
        setCards([howToReadCard()] + Scenarios.all.map(card(for:)))
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

    /// Builds one scenario's card, with its interactive body where it has one.
    ///
    /// A body that is also a Showcase demo is the same view on both screens.
    /// Scenarios with nothing to drive, such as the build-time one, render their
    /// Do / Expect text alone.
    ///
    /// - Parameter scenario: The scenario to render.
    /// - Returns: The card.
    private func card(for scenario: Scenario) -> CardView {
        switch scenario.key {
        case Scenarios.customEventValueTypes.key:
            return makeScenarioCard(scenario: scenario, body: [CustomEventBodyView()])
        default:
            return makeScenarioCard(scenario: scenario)
        }
    }
}
