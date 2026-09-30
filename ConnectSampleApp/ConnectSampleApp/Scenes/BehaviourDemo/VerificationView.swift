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
import SwiftUI

/// Verification screen — one card per shipped fix, for regression runs rather
/// than as an integration reference.
///
/// Composed card by card in the React Native sample's order
/// (`VerificationScreen.tsx`), not by walking the scenario registry: the
/// signal, capture-control and modal cards appear as the same plain cards the
/// Showcase shows, and only the cards unique to this screen sit in a scenario
/// frame.
///
/// Nothing is filtered by platform: an Android-only card still renders here so
/// a tester can see what the other platform is expected to do, which is how the
/// React Native sample behaves.
struct VerificationView: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                howToReadCard

                ScenarioCardView(scenario: Scenarios.screenViewReferrer) {
                    NavigationLink(
                        destination: BehaviourRoute.screenViews.screen(ScreenViewsView())
                    ) {
                        Text("Open Screen Views")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .connectIdentifier(SampleID.ScreenViews.open)
                }

                ScenarioCardView(scenario: Scenarios.customEventValueTypes) {
                    CustomEventBody()
                }

                SignalCard()

                IdentityDefaultsCard()

                MaskedFieldCard()

                AccessibilityMaskCard()

                CaptureControlCard()

                ScenarioCardView(scenario: Scenarios.webViewPostNotReplayedAsGet) {
                    NavigationLink(
                        destination: BehaviourRoute.webViewPost.screen(WebViewPostView())
                    ) {
                        Text("Open WebView form POST")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .connectIdentifier(SampleID.WebView.open)
                }

                ScenarioCardView(scenario: Scenarios.replayCapturesModal) {
                    CardBodyText("""
                        The two modal cards below present outside the navigation \
                        stack — one opaque full screen, one transparent over the \
                        screen beneath — the case that produced an empty control \
                        tree.
                        """)
                }

                ReplayModalCard()

                ReplayModalCard(transparent: true)

                ScenarioCardView(scenario: Scenarios.androidCompileClasspath) {
                    Text("""
                        Verified by the Android sample building at all — a broken \
                        compile classpath fails the Android build outright.
                        """)
                        .font(.caption)
                        .foregroundStyle(Color("violet"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(alignment: .leading) {
                            HStack(spacing: 0) {
                                Color("acousticGreen").frame(width: 3)
                                Color("lightGrey")
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("background"))
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
