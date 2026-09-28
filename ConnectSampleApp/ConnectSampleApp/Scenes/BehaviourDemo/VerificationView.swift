//
// Copyright (C) 2026 Acoustic, L.P. All rights reserved.
//
// Licensed under the Acoustic License (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy
// at https://www.acoustic.com/licenses/acoustic-license
//
// Sample app provided "as is", without warranty of any kind.
//

import SwiftUI

/// Verification screen — one card per shipped fix, for regression runs rather
/// than as an integration reference.
///
/// Nothing is filtered by platform: an Android-only card still renders here so
/// a tester can see what the other platform is expected to do, which is how the
/// React Native sample behaves.
///
/// Cards whose body is also a Showcase demo share that body rather than
/// duplicating it — the body is the demo, the frame is per screen.
struct VerificationView: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                howToReadCard

                ForEach(Scenarios.all) { scenario in
                    ScenarioCardView(scenario: scenario) {
                        cardBody(for: scenario)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("background"))
    }

    // MARK: - Scenario bodies

    /// The interactive body for a scenario, where one exists.
    ///
    /// A body that is also a Showcase demo is the same view on both screens —
    /// the body is the demo, the frame is per screen. Scenarios with nothing to
    /// drive, such as the build-time one, render their Do / Expect text alone.
    ///
    /// - Parameter scenario: The scenario being rendered.
    /// - Returns: The controls for that scenario.
    @ViewBuilder
    private func cardBody(for scenario: Scenario) -> some View {
        switch scenario.key {
        case Scenarios.customEventValueTypes.key:
            CustomEventBody()
        default:
            EmptyView()
        }
    }

    // MARK: - Cards

    private var howToReadCard: some View {
        DemoCard(title: "How to read these cards") {
            VStack(alignment: .leading, spacing: 8) {
                Text("""
                    Each card names one fix, what to do, and what a fixed build \
                    produces. Drive the card, background the app so iOS posts, then \
                    read the message at the collector configured in \
                    ConnectSDKManager.
                    """)
                Text("""
                    A card marked "Baseline only" has no published artifact carrying \
                    its fix. It still runs, deliberately — the failing result is the \
                    baseline that makes a later re-run meaningful. Do not read it as \
                    a pass.
                    """)
            }
            .font(.subheadline)
            .foregroundStyle(Color("darkGrey"))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    NavigationView {
        VerificationView()
    }
}
