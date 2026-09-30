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

/// Checks that masking reaches the captured accessibility object, for the
/// `accessibility-label-masking` scenario, matching `AccessibilityMaskCard` in
/// the SwiftUI sample.
///
/// A `UILabel`'s accessibility label is its own text unless the app sets one,
/// so row 1 — no explicit label — is the case a regression would break first.
/// The address matches the email rule in `ConnectLayoutConfig.json`, which is
/// what makes these elements masked at all.
@MainActor
final class AccessibilityMaskCardBody: UIStackView {

    private static let address = "analyticsp2@test.com"

    /// The body in its scenario card.
    static func makeCard() -> CardView {
        makeScenarioCard(scenario: Scenarios.accessibilityLabelMasking, body: [AccessibilityMaskCardBody()])
    }

    init() {
        super.init(frame: .zero)

        axis = .vertical
        spacing = 10

        addArrangedSubview(row("1 · no explicit label", identifier: SampleID.Verification.accessibilityImplicit))
        addArrangedSubview(
            row(
                "2 · explicit label",
                identifier: SampleID.Verification.accessibilityExplicit,
                label: "Email address"
            )
        )
        addArrangedSubview(
            row(
                "3 · label + accessibilityValue",
                identifier: SampleID.Verification.accessibilityValue,
                label: "Email address",
                value: Self.address
            )
        )
        addArrangedSubview(makeHintBox("""
            In each row's accessibility object the label should be masked per the \
            config's Sensitive rules — lowercase to x, digits to 9, symbols to #. \
            accessibility.id stays readable on purpose.
            """))
        addArrangedSubview(
            makeLabeledTextField(
                label: "Masked input (for comparison)",
                placeholder: "SECRET-1234",
                field: UITextField(),
                identifier: SampleID.Verification.accessibilityField
            )
        )
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func row(_ caption: String, identifier: String, label: String? = nil, value: String? = nil) -> UIView {
        let captionLabel = UILabel()
        captionLabel.text = caption
        captionLabel.font = .monospacedSystemFont(ofSize: 11, weight: .bold)
        captionLabel.textColor = UIColor(named: "darkGrey")

        let valueLabel = UILabel()
        valueLabel.text = Self.address
        valueLabel.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        valueLabel.textColor = UIColor(named: "violet")
        valueLabel.accessibilityIdentifier = identifier
        valueLabel.accessibilityLabel = label
        valueLabel.accessibilityValue = value

        let stack = UIStackView(arrangedSubviews: [captionLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }
}
