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

/// Runtime capture control. Shared by the Showcase and the Verification screen.
///
/// Tap Disable, move between screens, then Re-enable. Nothing from the disabled
/// stretch should reach the collector. Watch the posts after re-enabling as
/// well as during: a build that keeps recording while disabled and posts the
/// backlog on re-enable passes a check that only watches the disabled stretch.
struct CaptureControlCard: View {

    @ObservedObject private var store = BehaviourStore.shared

    var body: some View {
        DemoCard(title: "Runtime capture control") {
            VStack(alignment: .leading, spacing: 10) {
                CardBodyText("""
                    disable() is meant to stop capture. Confirm it on the build in \
                    front of you rather than assuming: tap Disable, navigate a few \
                    screens, then Re-enable. Nothing from the disabled stretch \
                    should reach the collector — not while disabled, and not after \
                    re-enabling either.
                    """)

                Button("Disable SDK") {
                    store.disableCapture()
                }
                .buttonStyle(PrimaryButtonStyle())
                .connectIdentifier(SampleID.Showcase.captureDisable)

                Button("Re-enable SDK") {
                    store.enableCapture()
                }
                .buttonStyle(PrimaryButtonStyle())
                .connectIdentifier(SampleID.Showcase.captureEnable)

                if let state = store.captureState {
                    ResultText(text: state, identifier: SampleID.Showcase.captureState)
                }
            }
        }
    }
}

#Preview {
    CaptureControlCard()
        .padding()
}
