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

/// Behaviour tab root — a hub with two entry points into the analytics half of
/// the SDK.
///
/// - **Showcase** is the general-purpose demo: one card per capture feature,
///   written for someone integrating the SDK for the first time.
/// - **Verification** is the release-verification surface: one card per shipped
///   fix, each stating what to do and what a fixed build produces.
///
/// Both live in the same navigation stack because several cards need somewhere
/// to navigate to — screen-view logging only fires on a real navigation, and
/// pushing and popping is itself part of what the screen-view cards show.
///
/// `NavigationView` rather than `NavigationStack`: this sample deploys to iOS
/// 15.1, where `NavigationStack` does not exist. Every push here is a user tap
/// on a link, so the declarative form is enough and the deprecated
/// `NavigationLink(isActive:)` is not needed.
struct BehaviourDemoView: View {

    var body: some View {
        NavigationView {
            hub
                .navigationTitle("Behaviour")
                .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
        .tint(Color("periwinkle"))
    }

    // MARK: - Hub

    private var hub: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                showcaseCard
                verificationCard
                footnote
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("background"))
        .logsScreenView(named: BehaviourRoute.hubScreenName)
    }

    private var headerView: some View {
        VStack(spacing: 6) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(height: 36)
            Text("Behaviour")
                .font(.title3.bold())
                .foregroundStyle(Color("violet"))
        }
        .padding(.top, 24)
    }

    private var showcaseCard: some View {
        DemoCard(title: "Showcase") {
            VStack(alignment: .leading, spacing: 10) {
                Text("""
                    What the SDK captures once it is enabled: screen views, taps, \
                    text entry, custom events, signals, dialogs, exceptions and \
                    session replay of modals. One card per feature, each with the \
                    call it makes and where to read the result.
                    """)
                    .font(.subheadline)
                    .foregroundStyle(Color("darkGrey"))
                    .frame(maxWidth: .infinity, alignment: .leading)

                NavigationLink(destination: BehaviourRoute.showcase.screen(ShowcaseView())) {
                    Text("Open Showcase")
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityIdentifier(SampleID.Behaviour.openShowcase)
            }
        }
    }

    private var verificationCard: some View {
        DemoCard(title: "Verification") {
            VStack(alignment: .leading, spacing: 10) {
                Text("""
                    Release-verification checks. Each card verifies one shipped fix \
                    against the SDK build this app is running, with the steps to \
                    follow and the payload to expect. Intended for regression runs \
                    rather than as an integration reference.
                    """)
                    .font(.subheadline)
                    .foregroundStyle(Color("darkGrey"))
                    .frame(maxWidth: .infinity, alignment: .leading)

                NavigationLink(destination: BehaviourRoute.verification.screen(VerificationView())) {
                    Text("Open Verification")
                }
                .buttonStyle(SecondaryButtonStyle())
                .accessibilityIdentifier(SampleID.Behaviour.openVerification)
            }
        }
    }

    private var footnote: some View {
        Text("""
            Both screens post to the collector configured in ConnectSDKManager. \
            iOS posts when the app is backgrounded, so background the app and read \
            the messages there.
            """)
            .font(.caption)
            .foregroundStyle(Color("darkGrey"))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
    }
}

#Preview {
    BehaviourDemoView()
}
