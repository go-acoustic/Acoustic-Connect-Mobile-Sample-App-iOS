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

/// Identity defaults, the contrast pair for the `identity-login-method-default`
/// scenario.
///
/// The first button omits both optional arguments, so the SDK supplies its own
/// defaults. The fix the scenario covers is in React Native's bridge, which
/// defaulted to the wrong parameter; this app calls the native SDK directly,
/// whose defaults are `signalType: pageView` with no parameters. The second
/// button is the explicit `accountRegistered` case, so a correct
/// `registrationMethod` can be told apart from a defaulting bug.
struct IdentityDefaultsCard: View {

    @ObservedObject private var store = BehaviourStore.shared

    var body: some View {
        ScenarioCardView(scenario: Scenarios.identityLoginMethodDefault) {
            VStack(alignment: .leading, spacing: 10) {
                Button("Log identity — omit both optional args") {
                    store.logIdentityDefaulted()
                }
                .buttonStyle(PrimaryButtonStyle())
                .connectIdentifier(SampleID.Verification.identityDefaulted)

                Button("Log accountRegistered — explicit") {
                    store.logIdentityExplicit()
                }
                .buttonStyle(SecondaryButtonStyle())
                .connectIdentifier(SampleID.Verification.identityExplicit)

                if let result = store.identityDefaultsResult {
                    ResultText(text: result, identifier: SampleID.Verification.identityDefaultsResult)
                }
            }
        }
    }
}

#Preview {
    IdentityDefaultsCard()
        .padding()
}
