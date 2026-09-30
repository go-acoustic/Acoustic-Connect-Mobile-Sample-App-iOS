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

/// Checks that masking reaches the captured accessibility object, for the
/// `accessibility-label-masking` scenario.
///
/// Masking used to redact an element's value but serialise its accessibility
/// label and hint verbatim, so text a mask rule was meant to hide still
/// travelled in `accessibility.label`. A `Text` view's accessibility label is
/// its own content unless the app sets one, so row 1 — no explicit label — is
/// the case a regression would break first.
///
/// The address matches the email rule in `ConnectLayoutConfig.json`, which is
/// what makes these elements masked at all. Without that rule nothing here is
/// masked and every row reads as a leak.
struct AccessibilityMaskCard: View {

    private static let address = "analyticsp2@test.com"

    @State private var typed = ""

    var body: some View {
        ScenarioCardView(scenario: Scenarios.accessibilityLabelMasking) {
            VStack(alignment: .leading, spacing: 10) {
                row("1 · no explicit label") {
                    Text(Self.address)
                        .connectIdentifier(SampleID.Verification.accessibilityImplicit)
                }

                row("2 · explicit label") {
                    Text(Self.address)
                        .accessibilityLabel("Email address")
                        .connectIdentifier(SampleID.Verification.accessibilityExplicit)
                }

                row("3 · label + accessibilityValue") {
                    Text(Self.address)
                        .accessibilityLabel("Email address")
                        .accessibilityValue(Self.address)
                        .connectIdentifier(SampleID.Verification.accessibilityValue)
                }

                HintText("""
                    In each row's accessibility object the label should be masked \
                    per the config's Sensitive rules — lowercase to x, digits to 9, \
                    symbols to #. accessibility.id stays readable on purpose.
                    """)

                DemoTextField(
                    label: "Masked input (for comparison)",
                    placeholder: "SECRET-1234",
                    text: $typed,
                    identifier: SampleID.Verification.accessibilityField
                )
            }
        }
    }

    private func row<Value: View>(_ caption: String, @ViewBuilder value: () -> Value) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(caption)
                .font(.caption2.bold())
                .foregroundStyle(Color("darkGrey"))
            value()
                .font(.system(.subheadline, design: .monospaced))
                .foregroundStyle(Color("violet"))
        }
    }
}

#Preview {
    AccessibilityMaskCard()
        .padding()
}
