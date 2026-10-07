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

/// The pushed screen for one screen-name case. Arriving here is the event under
/// test: the screen named itself with the case's name as it appeared, so a
/// type-2 message with that exact name is already on its way to the collector.
///
/// The screen prints the name it was entered with, so a tester can match what
/// the app claims to have logged against what the collector received and what
/// the inferred signal's `url` ends up being. Pushing a further case builds a
/// deeper stack, which checks that the top screen's name is what gets logged.
/// Mirrors `ScreenViewCaseScreen.tsx` in the React Native sample.
struct ScreenViewCaseView: View {

    let screenViewCase: ScreenViewCase

    @State private var relogged: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                loggedNameCard
                expectedCard
                repeatCard
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("background"))
    }

    // MARK: - Cards

    private var loggedNameCard: some View {
        DemoCard(title: "Logged screen name") {
            VStack(alignment: .leading, spacing: 8) {
                Text(ScreenViewCases.describe(screenViewCase.name))
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundStyle(Color("violet"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(screenViewCase.name?.utf16.count ?? 0) characters · this screen's page name")
                    .font(.caption2)
                    .foregroundStyle(Color("darkGrey"))
                CardBodyText(screenViewCase.probes)
            }
        }
    }

    private var expectedCard: some View {
        DemoCard(title: "Expected result") {
            CardBodyText("""
                The type-2 message should carry screenview.name exactly as shown \
                above, and the inferred pageView signal should carry the same string \
                as signalContent.url — valid, not in the invalid-signal topic.
                """)
        }
    }

    private var repeatCard: some View {
        DemoCard(title: "Repeat") {
            VStack(alignment: .leading, spacing: 10) {
                CardBodyText("""
                    Re-send the same name through the direct call, to compare the \
                    navigation-driven message against an explicit one.
                    """)

                Button("Log this name directly") {
                    let queued = BehaviourStore.shared.logScreenViewDirect(
                        name: screenViewCase.name,
                        referrer: BehaviourRoute.screenViews.screenName
                    )
                    relogged = "\(queued ? "✓" : "✗") re-logged directly"
                }
                .buttonStyle(PrimaryButtonStyle())
                .connectIdentifier(SampleID.ScreenViews.caseRelog)

                if let relogged {
                    ResultText(text: relogged, identifier: SampleID.ScreenViews.caseRelogResult)
                }

                if let next = ScreenViewCases.next(after: screenViewCase) {
                    NavigationLink(
                        destination: BehaviourRoute.screenViewCase(next)
                            .screen(ScreenViewCaseView(screenViewCase: next))
                    ) {
                        Text("Push deeper — \(next.label)")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .connectIdentifier(SampleID.ScreenViews.casePushNext)
                    .padding(.top, 4)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ScreenViewCaseView(screenViewCase: ScreenViewCases.realistic[0])
    }
}
