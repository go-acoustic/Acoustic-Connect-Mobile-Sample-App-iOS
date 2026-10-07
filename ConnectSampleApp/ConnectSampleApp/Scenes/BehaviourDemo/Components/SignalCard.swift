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

/// `logSignal` card — the on-device check that a nested signal payload reaches
/// the collector with its structure intact. Shared by the Showcase and the
/// Verification screen.
///
/// The nested button sends an object plus an array of objects; the flat button
/// sends scalars only, so a tester can confirm the same call still works for
/// existing callers. Both payloads are defined in ``BehaviourStore/Signal``.
struct SignalCard: View {

    @ObservedObject private var store = BehaviourStore.shared

    var body: some View {
        DemoCard(title: "Log Signal") {
            VStack(alignment: .leading, spacing: 10) {
                CardBodyText("""
                    Sends a signal through logSignal(_:level:). The nested payload \
                    carries an object and an array of objects; the flat one is \
                    scalars only. Compare the signal block in the posted type-21 \
                    message across platforms.
                    """)

                Button("Send Nested Signal") {
                    store.logSignal(.nested)
                }
                .buttonStyle(PrimaryButtonStyle())
                .connectIdentifier(SampleID.Showcase.sendNestedSignal)

                Button("Send Flat Signal") {
                    store.logSignal(.flat)
                }
                .buttonStyle(SecondaryButtonStyle())
                .connectIdentifier(SampleID.Showcase.sendFlatSignal)

                if let result = store.signalResult {
                    ResultText(text: result, identifier: SampleID.Showcase.signalResult)
                        .padding(10)
                        .background(Color("lightGrey"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}

#Preview {
    SignalCard()
        .padding()
}
