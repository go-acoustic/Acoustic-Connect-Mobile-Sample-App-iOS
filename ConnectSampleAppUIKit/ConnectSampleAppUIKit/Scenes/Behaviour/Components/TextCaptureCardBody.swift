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

/// Text capture and masking demo, matching `TextCaptureCard` in the SwiftUI
/// sample.
///
/// Edits to any text field are logged as text-change events, and the field's
/// value is part of the captured screen layout. Values matching a
/// `MaskValueList` rule in `ConnectLayoutConfig.json` arrive masked — the
/// samples ship a rule for values starting with `SECRET-`, which the second
/// field is there to hit.
@MainActor
final class TextCaptureCardBody: UIStackView {

    /// The body in its card.
    static func makeCard() -> CardView {
        CardView(title: "Text entry and masking", arrangedSubviews: [TextCaptureCardBody()])
    }

    init() {
        super.init(frame: .zero)

        axis = .vertical
        spacing = 10

        addArrangedSubview(makeBodyLabel("""
            Typing into a field logs a text-change event and the value appears \
            in the captured layout. A value matching a masking rule in \
            ConnectLayoutConfig.json is redacted before it leaves the device.
            """))
        addArrangedSubview(
            makeLabeledTextField(
                label: "Plain field",
                placeholder: "Anything you type is captured",
                field: UITextField(),
                identifier: SampleID.Showcase.note
            )
        )
        addArrangedSubview(
            makeLabeledTextField(
                label: "Masked field",
                placeholder: "SECRET-1234",
                field: UITextField(),
                identifier: SampleID.Showcase.secret
            )
        )

        addArrangedSubview(makeHintBox("""
            The sample config masks values starting with SECRET-: capitals \
            become X, lowercase x, digits 9 and symbols #. Compare the two \
            fields in the posted layout message.
            """))
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
