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

/// Checks that value, id and password rules reach every captured surface — the
/// layout text, the identifiers, the tap target and the screenshot that comes
/// with the tap — for the `masking-value-id-rules` scenario, matching
/// `MaskingRulesCardBody` in the UIKit sample.
///
/// The address and the `SECRET-` prefix match `MaskValueList`, and row 3
/// matches the `MaskAccessibilityIdList` rule for its identifier, in
/// `ConnectLayoutConfig.json`. The email and password fields are filled in from
/// the start, so the layout captured when the screen opens carries their
/// values; text typed into the last field is not in that layout, so the tap's
/// screenshot is where it must be obscured.
struct MaskingRulesCard: View {
    private static let address = "analyticsp2@test.com"

    @State private var email = Self.address
    @State private var password = "sample-pass-42"
    @State private var typed = ""
    @State private var sent = false

    var body: some View {
        ScenarioCardView(scenario: Scenarios.maskingValueIdRules) {
            VStack(alignment: .leading, spacing: 10) {
                row("1 · value rule, with a label") {
                    Text(Self.address)
                        .accessibilityLabel("Contact email")
                        .connectIdentifier(SampleID.Verification.maskRulesLabelled)
                }
                row("2 · value rule, no label") {
                    Text(Self.address)
                        .connectIdentifier(SampleID.Verification.maskRulesUnlabelled)
                }
                row("3 · id rule") {
                    Text("4111 1111 1111 1111")
                        .accessibilityLabel("Card number")
                        .connectIdentifier(SampleID.Verification.maskRulesCard)
                }
                DemoTextField(
                    label: "Email field",
                    placeholder: Self.address,
                    text: $email,
                    identifier: SampleID.Verification.maskRulesEmailField
                )
                DemoTextField(
                    label: "Password",
                    placeholder: "",
                    text: $password,
                    identifier: SampleID.Verification.maskRulesPassword,
                    isSecure: true
                )
                DemoTextField(
                    label: "Typed value",
                    placeholder: "SECRET-1234",
                    text: $typed,
                    identifier: SampleID.Verification.maskRulesTyped
                )
                Button("Send to \(Self.address)") {
                    sent = true
                }
                .buttonStyle(PrimaryButtonStyle())
                .connectIdentifier(SampleID.Verification.maskRulesSend)

                if sent {
                    ResultText(
                        text: "Tap sent. Its screenshot should obscure every masked row above, the typed one included.",
                        identifier: SampleID.Verification.maskRulesResult
                    )
                }
                HintText("""
                    In the layout message rows 1 and 2 and the email field should \
                    read xxxxxxxxxx9#xxxx#xxx, row 3 9999 9999 9999 9999, and the \
                    password field masked per the same Sensitive rules — never the \
                    typed password. Text typed into the last field is not in the \
                    layout, which is captured when the screen opens; it should be \
                    obscured in the screenshot that comes with the tap.
                    """)
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
    MaskingRulesCard()
        .padding()
}
