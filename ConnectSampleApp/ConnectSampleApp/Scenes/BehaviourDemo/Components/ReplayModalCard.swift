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

/// Session-replay reference for a full-screen modal.
///
/// A modal is presented by its own view controller rather than pushed onto the
/// navigation stack, so session replay has to resolve its controls outside the
/// stack the rest of the app lives in. The controls are deliberately varied —
/// text, a bordered text field, two buttons and a status line — so a replay
/// reviewer can confirm each one is individually inspectable rather than just
/// seeing a correct-looking screenshot.
///
/// The status line echoes the note and the action count, so an interaction that
/// never registered can be told apart from one the SDK failed to capture.
struct ReplayModalCard: View {

    /// The screen name to restore when the modal closes — the screen the card
    /// sits on.
    ///
    /// Dismissing a full-screen cover does not re-run the presenting screen's
    /// `onAppear`, so without this the next screen view would still carry the
    /// modal's name.
    let returnScreenName: String

    @State private var isPresented = false

    var body: some View {
        DemoCard(title: "Modal (opaque)") {
            VStack(alignment: .leading, spacing: 10) {
                CardBodyText("""
                    Opens a full-screen modal. Every element inside it should be \
                    selectable in session replay, not just visible in the \
                    screenshot.
                    """)

                Button("Open modal") {
                    isPresented = true
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityIdentifier(SampleID.ReplayModal.openOpaque)
            }
        }
        .fullScreenCover(isPresented: $isPresented) {
            ReplayModalContent {
                SampleScreenNaming.nameCurrentScreen(returnScreenName)
                isPresented = false
            }
        }
    }
}

/// The modal's contents, on the sample's background colour.
private struct ReplayModalContent: View {

    let close: () -> Void

    @State private var note = ""
    @State private var actionCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Modal content")
                .font(.headline)
                .foregroundStyle(Color("violet"))

            CardBodyText("""
                Text, a field and buttons — each should appear as its own control \
                in the captured layout.
                """)

            DemoTextField(
                label: "Note",
                placeholder: "Type to check text capture",
                text: $note,
                identifier: SampleID.ReplayModal.note
            )

            Button("Primary action") {
                actionCount += 1
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityIdentifier(SampleID.ReplayModal.action)

            Button("Close", action: close)
                .buttonStyle(SecondaryButtonStyle())
                .accessibilityIdentifier(SampleID.ReplayModal.close)

            Text("Note: \(note.isEmpty ? "—" : note) · Primary action taps: \(actionCount)")
                .font(.caption)
                .foregroundStyle(Color("violet"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier(SampleID.ReplayModal.result)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("background"))
        .logsScreenView(named: BehaviourRoute.replayModalScreenName)
    }
}

#Preview {
    ReplayModalCard(returnScreenName: BehaviourRoute.showcase.screenName)
        .padding()
}
