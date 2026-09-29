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

/// Showcase screen — the general-purpose demo of the SDK's behaviour capture,
/// written for someone integrating it for the first time. Reached from the
/// Behaviour hub.
///
/// Ordering follows what an integrator meets first: the things the SDK captures
/// with no code (screen views, taps, text), then the explicit logging calls
/// (custom events, signals, exceptions), then dialogs and modals, and finally
/// runtime control.
///
/// Cards that also serve a verification scenario share their body with
/// ``VerificationView`` — the body is the demo, the frame is per screen.
struct ShowcaseView: View {

    private static let firstDetail = BehaviourRoute.showcaseDetail(name: "Showcase detail", depth: 1)

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                howToReadCard
                screenViewsCard
                ClickCaptureCard()
                TextCaptureCard()
                customEventCard
                SignalCard()
                ExceptionCard()
                DialogCard()
                ReplayModalCard(returnScreenName: BehaviourRoute.showcase.screenName)
                CaptureControlCard()
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
        DemoCard(title: "How to read the results") {
            VStack(alignment: .leading, spacing: 8) {
                Text("""
                    Every card sends something to the collector configured in \
                    ConnectSDKManager. Drive a card, then read the posted message \
                    there. iOS posts when the app is backgrounded.
                    """)
                Text("""
                    The first three cards need no SDK call at all — enabling the \
                    SDK is what captures them.
                    """)
            }
            .font(.subheadline)
            .foregroundStyle(Color("darkGrey"))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var screenViewsCard: some View {
        DemoCard(title: "Screen views") {
            VStack(alignment: .leading, spacing: 10) {
                Text("""
                    Every navigation logs a screen view. iOS names it after the view \
                    controller's class unless the app supplies a name, so these \
                    screens set theirs explicitly; the referrer is the screen you \
                    came from.
                    """)
                    .font(.subheadline)
                    .foregroundStyle(Color("darkGrey"))
                    .frame(maxWidth: .infinity, alignment: .leading)

                NavigationLink(
                    destination: Self.firstDetail.screen(
                        ShowcaseDetailView(name: "Showcase detail", depth: 1)
                    )
                ) {
                    Text("Open a detail screen")
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityIdentifier(SampleID.Showcase.openDetail)
            }
        }
    }

    private var customEventCard: some View {
        DemoCard(title: "Custom event") {
            VStack(alignment: .leading, spacing: 10) {
                Text("""
                    logEvent(_:values:level:) sends a named event with a flat map of \
                    string, number and boolean values. Read it under customEvent in \
                    the posted message.
                    """)
                    .font(.subheadline)
                    .foregroundStyle(Color("darkGrey"))
                    .frame(maxWidth: .infinity, alignment: .leading)

                CustomEventBody()
            }
        }
    }
}

#Preview {
    NavigationView {
        ShowcaseView()
    }
}
