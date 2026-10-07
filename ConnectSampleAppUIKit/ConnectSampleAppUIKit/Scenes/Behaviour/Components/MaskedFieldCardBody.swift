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

/// Checks that the layout config in `ConnectLayoutConfig.json` reaches the SDK,
/// for the `layout-config-applied` scenario, matching `MaskedFieldCard` in the
/// SwiftUI sample. A value starting with `SECRET-` arrives masked only if the
/// config was applied.
@MainActor
final class MaskedFieldCardBody: UIStackView {

    /// The body in its scenario card.
    static func makeCard() -> CardView {
        makeScenarioCard(scenario: Scenarios.layoutConfigApplied, body: [MaskedFieldCardBody()])
    }

    init() {
        super.init(frame: .zero)

        axis = .vertical
        spacing = 10

        addArrangedSubview(
            makeLabeledTextField(
                label: "Masked field",
                placeholder: "SECRET-1234",
                field: UITextField(),
                identifier: SampleID.Verification.maskedField
            )
        )
        addArrangedSubview(makeHintBox("""
            Type a value starting with SECRET-, then background the app. In the \
            layout message the value should be masked per the config's Sensitive \
            rules — capitals to X, lowercase to x, digits to 9, symbols to # — \
            not the text you typed.
            """))
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
