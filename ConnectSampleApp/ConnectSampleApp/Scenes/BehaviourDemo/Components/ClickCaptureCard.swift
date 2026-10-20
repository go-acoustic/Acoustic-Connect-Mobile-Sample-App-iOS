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

/// Click capture demo. There is no SDK call here on purpose: once the SDK is
/// enabled, a tap on a view marked with `connectIdentifier(_:)` is logged as a
/// click event before the button handles it. SwiftUI draws its controls without
/// a `UIView`, so a tap on an unmarked view is not logged.
///
/// The counter is only there to show the tap registered with the app, so a tap
/// the SDK failed to log can be told apart from one that never happened.
struct ClickCaptureCard: View {

    @State private var taps = 0

    var body: some View {
        DemoCard(title: "Taps") {
            VStack(alignment: .leading, spacing: 10) {
                CardBodyText("""
                    Taps on views marked with connectIdentifier are logged as click \
                    events. Nothing to call — tap the button and look for the click \
                    event in the next post.
                    """)

                Button("Tap me") {
                    taps += 1
                }
                .buttonStyle(PrimaryButtonStyle())
                .connectIdentifier(SampleID.Showcase.tap)

                ResultText(text: "taps: \(taps)", identifier: SampleID.Showcase.tapCount)
            }
        }
    }
}

#Preview {
    ClickCaptureCard()
        .padding()
}
