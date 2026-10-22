//
// Copyright (C) 2026 Acoustic, L.P. All rights reserved.
//
// Licensed under the Acoustic License (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy
// at https://www.acoustic.com/licenses/acoustic-license
//
// Sample app provided "as is", without warranty of any kind.
//

import UIKit

/// Checks that value, id and password rules reach every captured surface, for
/// the `masking-value-id-rules` scenario, matching `MaskingRulesCard` in the
/// SwiftUI sample.
///
/// The address and the `SECRET-` prefix match `MaskValueList`, and row 3
/// matches the `MaskAccessibilityIdList` rule for its identifier, in
/// `ConnectLayoutConfig.json`. The password field is a secure text field, which
/// the SDK masks whatever the rules say.
@MainActor
final class MaskingRulesCardBody: UIStackView {

    private static let address = "analyticsp2@test.com"

    private let resultLabel = makeResultLabel(identifier: SampleID.Verification.maskRulesResult)

    /// The body in its scenario card.
    static func makeCard() -> CardView {
        makeScenarioCard(scenario: Scenarios.maskingValueIdRules, body: [MaskingRulesCardBody()])
    }

    init() {
        super.init(frame: .zero)

        axis = .vertical
        spacing = 10

        addArrangedSubview(row("1 · value rule, with a label", text: Self.address,
                               identifier: SampleID.Verification.maskRulesLabelled, label: "Contact email"))
        addArrangedSubview(row("2 · value rule, no label", text: Self.address,
                               identifier: SampleID.Verification.maskRulesUnlabelled))
        addArrangedSubview(row("3 · id rule", text: "4111 1111 1111 1111",
                               identifier: SampleID.Verification.maskRulesCard, label: "Card number"))

        // Filled in from the start, so the layout captured when the screen
        // opens carries the values.
        let email = UITextField()
        email.text = Self.address
        addArrangedSubview(makeLabeledTextField(label: "Email field", placeholder: Self.address,
                                                field: email, identifier: SampleID.Verification.maskRulesEmailField))
        let password = UITextField()
        password.text = "sample-pass-42"
        password.isSecureTextEntry = true
        addArrangedSubview(makeLabeledTextField(label: "Password", placeholder: "",
                                                field: password, identifier: SampleID.Verification.maskRulesPassword))
        addArrangedSubview(makeLabeledTextField(label: "Typed value", placeholder: "SECRET-1234",
                                                field: UITextField(), identifier: SampleID.Verification.maskRulesTyped))

        addArrangedSubview(
            makePrimaryButton(
                title: "Send to \(Self.address)",
                identifier: SampleID.Verification.maskRulesSend,
                action: UIAction { [weak self] _ in
                    self?.resultLabel.text = """
                        Tap sent. Its screenshot should obscure every masked row above, \
                        the typed one included.
                        """
                    self?.resultLabel.isHidden = false
                }
            )
        )
        addArrangedSubview(resultLabel)
        addArrangedSubview(makeHintBox("""
            In the layout message rows 1 and 2 and the email field should read \
            xxxxxxxxxx9#xxxx#xxx, row 3 9999 9999 9999 9999, and the password field \
            masked per the same Sensitive rules — never the typed password. Text \
            typed into the last field is not in the layout, which is captured when \
            the screen opens; it should be obscured in the screenshot that comes \
            with the tap.
            """))
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// A caption over the value label, which carries the row's identifier.
    /// `MaskAccessibilityIdList` matches a view's `accessibilityIdentifier`
    /// (`TLFMaskingManager willMask:`); whether the layout capture applies it
    /// to a `UILabel`'s text is what the card-number row checks.
    private func row(_ caption: String, text: String, identifier: String, label: String? = nil) -> UIView {
        let captionLabel = UILabel()
        captionLabel.text = caption
        captionLabel.font = .monospacedSystemFont(ofSize: 11, weight: .bold)
        captionLabel.textColor = UIColor(named: "darkGrey")

        let valueLabel = UILabel()
        valueLabel.text = text
        valueLabel.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        valueLabel.textColor = UIColor(named: "violet")
        valueLabel.accessibilityIdentifier = identifier
        valueLabel.accessibilityLabel = label

        let stack = UIStackView(arrangedSubviews: [captionLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }
}
