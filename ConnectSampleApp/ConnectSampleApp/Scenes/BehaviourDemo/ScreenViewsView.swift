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

/// Screen Views screen — the verification surface for the `pageView` signal
/// the platform infers from every screen view. Reached from the Verification
/// screen's `screenview-referrer` card.
///
/// A mobile screen view carries no URL, so the server-side rule falls back to
/// the screen's name for the inferred signal's `url`; each case below is one
/// test of that fallback. Drilling into a case is a real navigation, so the
/// name reaches the SDK the way a customer's app sends it. Mirrors
/// `ScreenViewsScreen.tsx` in the React Native sample.
struct ScreenViewsView: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                howToVerifyCard
                navigateCard
                DirectScreenViewCard()
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("background"))
    }

    // MARK: - Cards

    private var howToVerifyCard: some View {
        DemoCard(title: "How this is verified") {
            VStack(alignment: .leading, spacing: 10) {
                CardBodyText("""
                    Every screen view sends a type-2 message carrying the screen \
                    name. The platform derives a pageView signal from it; because a \
                    mobile screen has no URL, the server-side rule falls back to that \
                    name for the signal's url.
                    """)
                CardBodyText("""
                    So each button below is one test of that fallback. Drive them, \
                    then check the subscription's inferred pageView definition — \
                    valid count should rise and the Missing required field: [url] \
                    records should stop.
                    """)
                HintText("""
                    Do not press the Showcase or Verification Log Signal buttons \
                    during a run. They send an explicit pageview signal, and \
                    inference stands down for a subscription that sends its own — \
                    which would read as a pass when it is really a suppression.
                    """)
            }
        }
    }

    private var navigateCard: some View {
        DemoCard(title: "Navigate — real integration path") {
            VStack(alignment: .leading, spacing: 12) {
                CardBodyText("""
                    Pushes a screen that names itself with setCurrentScreen(pageName:) \
                    as it appears. Navigate back and re-enter to produce repeat views.
                    """)

                ForEach(ScreenViewCases.navigation) { screenViewCase in
                    VStack(alignment: .leading, spacing: 6) {
                        NavigationLink(
                            destination: BehaviourRoute.screenViewCase(screenViewCase)
                                .screen(ScreenViewCaseView(screenViewCase: screenViewCase))
                        ) {
                            Text(screenViewCase.label)
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .connectIdentifier(SampleID.ScreenViews.navigateButton(screenViewCase.id))

                        Text("logs: \(ScreenViewCases.describe(screenViewCase.name))")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(Color("violet"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
}

/// Sends type-2 screen views with an exact, arbitrary name through
/// `logScreenViewContext`, bypassing navigation. Mirrors
/// `DirectScreenViewCard.tsx` in the React Native sample.
///
/// Navigation cannot carry an empty or `nil` name, so the two cases most likely
/// to still break the fallback are only reachable here.
struct DirectScreenViewCard: View {

    @ObservedObject private var store = BehaviourStore.shared

    var body: some View {
        DemoCard(title: "Screen view — exact name") {
            VStack(alignment: .leading, spacing: 12) {
                CardBodyText("""
                    Emits a type-2 screenview whose logical page name is the exact \
                    string below. The server-side rule uses that name as the \
                    inferred pageView's url, so each name is a separate test of the \
                    fallback. The empty and null names are only reachable here — \
                    navigation drops them.
                    """)

                Button("Send all \(ScreenViewCases.direct.count) names") {
                    store.logAllScreenViewsDirect()
                }
                .buttonStyle(PrimaryButtonStyle())
                .connectIdentifier(SampleID.ScreenViews.sendAll)

                ForEach(ScreenViewCases.direct) { screenViewCase in
                    VStack(alignment: .leading, spacing: 6) {
                        Button(screenViewCase.label) {
                            store.logScreenViewDirect(screenViewCase)
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .connectIdentifier(SampleID.ScreenViews.directButton(screenViewCase.id))

                        Text(screenViewCase.probes)
                            .font(.caption2)
                            .foregroundStyle(Color("darkGrey"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                if let newest = store.screenViewLog.first {
                    VStack(alignment: .leading, spacing: 4) {
                        ResultText(text: newest.line, identifier: SampleID.ScreenViews.result)
                        ForEach(store.screenViewLog.dropFirst()) { entry in
                            Text(entry.line)
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundStyle(Color("violet"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(10)
                    .background(Color("lightGrey"))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ScreenViewsView()
    }
}
