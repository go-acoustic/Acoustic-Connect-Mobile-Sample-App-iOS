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

/// Checks that the layout config in `ConnectLayoutConfig.json` reaches the SDK,
/// for the `layout-config-applied` scenario.
///
/// Masking is the observable proxy: the config's `MaskValueList` masks values
/// starting with `SECRET-`, so a value typed here arrives masked if the config
/// was applied and verbatim if it was dropped. Nothing in the app changes when
/// a config is silently ignored, so the posted layout is the only place the
/// difference shows.
struct MaskedFieldCard: View {

    @State private var value = ""

    var body: some View {
        ScenarioCardView(scenario: Scenarios.layoutConfigApplied) {
            VStack(alignment: .leading, spacing: 10) {
                DemoTextField(
                    label: "Masked field",
                    placeholder: "SECRET-1234",
                    text: $value,
                    identifier: SampleID.Verification.maskedField
                )

                HintText("""
                    Type a value starting with SECRET-, then background the app. In \
                    the layout message the value should be masked per the config's \
                    Sensitive rules — capitals to X, lowercase to x, digits to 9, \
                    symbols to # — not the text you typed.
                    """)
            }
        }
    }
}

#Preview {
    MaskedFieldCard()
        .padding()
}
