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

/// Text capture and masking demo.
///
/// Edits to any text field are logged as text-change events, and the field's
/// value is part of the captured screen layout. Values matching a
/// `MaskValueList` rule in `ConnectLayoutConfig.json` arrive masked — the
/// samples ship a rule for values starting with `SECRET-`, which the second
/// field is there to hit.
struct TextCaptureCard: View {

    @State private var note = ""
    @State private var secret = ""

    var body: some View {
        DemoCard(title: "Text entry and masking") {
            VStack(alignment: .leading, spacing: 10) {
                CardBodyText("""
                    Typing into a field logs a text-change event and the value \
                    appears in the captured layout. A value matching a masking \
                    rule in ConnectLayoutConfig.json is redacted before it leaves \
                    the device.
                    """)

                DemoTextField(
                    label: "Plain field",
                    placeholder: "Anything you type is captured",
                    text: $note,
                    identifier: SampleID.Showcase.note
                )

                DemoTextField(
                    label: "Masked field",
                    placeholder: "SECRET-1234",
                    text: $secret,
                    identifier: SampleID.Showcase.secret
                )

                Text("""
                    The sample config masks values starting with SECRET-: capitals \
                    become X, lowercase x, digits 9 and symbols #. Compare the two \
                    fields in the posted layout message.
                    """)
                    .font(.caption)
                    .foregroundStyle(Color("violet"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color("lightGrey"))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

#Preview {
    TextCaptureCard()
        .padding()
}
