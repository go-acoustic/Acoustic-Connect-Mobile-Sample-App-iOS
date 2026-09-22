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

/// Behaviour tab — the analytics half of the SDK.
///
/// Screen views, taps and text entry are captured with no code once the SDK is
/// enabled; this tab covers the explicit logging calls on top of that. It is
/// deliberately small for now, with one card per capability added as the
/// showcase grows.
struct BehaviourDemoView: View {

    @ObservedObject private var store = BehaviourStore.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                resultSection
                automaticCaptureCard
                customEventCard
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("background"))
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 6) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(height: 36)
            Text("Behaviour Demo")
                .font(.title3.bold())
                .foregroundStyle(Color("violet"))
        }
        .padding(.top, 24)
    }

    // MARK: - Automatic capture card

    private var automaticCaptureCard: some View {
        DemoCard(title: "Captured Automatically") {
            VStack(alignment: .leading, spacing: 8) {
                Text("""
                    Enabling the SDK is enough to capture screen views, taps and text \
                    entry — no calls needed. Moving between these tabs already logs \
                    screen views.
                    """)
                    .font(.subheadline)
                    .foregroundStyle(Color("darkGrey"))
                Text("iOS posts to the collector when the app is backgrounded, so background the app and read the messages there.")
                    .font(.caption)
                    .foregroundStyle(Color("darkGrey"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Custom event card

    private var customEventCard: some View {
        DemoCard(title: "Custom Event") {
            VStack(alignment: .leading, spacing: 10) {
                Text("""
                    logEvent(name:values:) sends a named event with a flat map of \
                    string, number and boolean values. Read it under customEvent in \
                    the posted message.
                    """)
                    .font(.subheadline)
                    .foregroundStyle(Color("darkGrey"))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button("Log Custom Event") {
                    store.logCustomEvent()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }

    // MARK: - Result section

    @ViewBuilder
    private var resultSection: some View {
        if let result = store.lastResult {
            DemoCard(title: "Last Result") {
                Text(result)
                    .font(.subheadline)
                    .foregroundStyle(Color("darkGrey"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    BehaviourDemoView()
}
