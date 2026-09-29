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

/// Dialog capture demo. There is no SDK call here: the alert is presented
/// exactly as any app presents one, and the SDK logs it on its own.
struct DialogCard: View {

    @State private var isShowingDialog = false
    @State private var last: String?

    var body: some View {
        DemoCard(title: "Dialogs") {
            VStack(alignment: .leading, spacing: 10) {
                CardBodyText("""
                    Opens a standard alert. The SDK logs the alert and the button \
                    pressed, with no change to how the alert is presented.
                    """)

                Button("Show a dialog") {
                    isShowingDialog = true
                }
                .buttonStyle(PrimaryButtonStyle())
                .connectIdentifier(SampleID.Showcase.dialog)

                if let last {
                    ResultText(text: last, identifier: SampleID.Showcase.dialogResult)
                }
            }
        }
        .alert("Showcase dialog", isPresented: $isShowingDialog) {
            Button("Cancel", role: .cancel) { last = "Cancel pressed" }
            Button("OK") { last = "OK pressed" }
        } message: {
            Text("Pick a button — each press is logged.")
        }
    }
}

#Preview {
    DialogCard()
        .padding()
}
