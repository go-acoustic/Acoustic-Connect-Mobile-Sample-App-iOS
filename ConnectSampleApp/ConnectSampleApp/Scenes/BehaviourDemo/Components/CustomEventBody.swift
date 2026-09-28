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

/// `logEvent` demo body, shared by the Showcase — inside a plain ``DemoCard`` —
/// and the Verification screen, inside a ``ScenarioCardView``.
///
/// The body is the demo and the frame is per screen, so the two screens cannot
/// drift into demonstrating the same call two different ways.
struct CustomEventBody: View {

    @ObservedObject private var store = BehaviourStore.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(BehaviourStore.customEventPayloadDisplay)
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(Color("violet"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color("lightGrey"))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Button("Send custom event") {
                store.logCustomEvent()
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityIdentifier(SampleID.Showcase.sendCustomEvent)

            if let result = store.customEventResult {
                Text(result)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(Color("violet"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier(SampleID.Showcase.customEventResult)
            }
        }
    }
}

#Preview {
    DemoCard(title: "Custom event") {
        CustomEventBody()
    }
    .padding()
}
