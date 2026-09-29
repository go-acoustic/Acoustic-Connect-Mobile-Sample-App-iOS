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

/// `logNSExceptionEvent` demo.
///
/// Uncaught Objective-C exceptions are reported by the SDK on its own. This
/// card covers the other case: an error the app caught and recovered from,
/// which is invisible to the SDK unless the app reports it. `unhandled` is
/// `false` because the app handled it.
struct ExceptionCard: View {

    @ObservedObject private var store = BehaviourStore.shared

    var body: some View {
        DemoCard(title: "Exceptions") {
            VStack(alignment: .leading, spacing: 10) {
                CardBodyText("""
                    Uncaught exceptions are reported automatically. For errors your \
                    app catches, logNSExceptionEvent(_:dataDictionary:isUnhandled:) \
                    reports them explicitly. This button throws, catches and \
                    reports one.
                    """)

                Button("Log a handled exception") {
                    store.logHandledException()
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityIdentifier(SampleID.Showcase.exception)

                if let result = store.exceptionResult {
                    ResultText(text: result, identifier: SampleID.Showcase.exceptionResult)
                }
            }
        }
    }
}

#Preview {
    ExceptionCard()
        .padding()
}
