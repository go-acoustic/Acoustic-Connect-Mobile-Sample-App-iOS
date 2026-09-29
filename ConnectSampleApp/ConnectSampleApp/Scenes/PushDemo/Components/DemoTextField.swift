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

struct DemoTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isDisabled: Bool = false

    /// Accessibility identifier for the field itself.
    ///
    /// The caption and the wrapping stack take the `_label` and `_container`
    /// suffixes React Native's `DemoTextField` adds, so one page object
    /// addresses the same three elements on every platform.
    var identifier: String?

    private var labelIdentifier: String {
        guard let identifier else { return "" }
        return SampleID.FieldPart.label(identifier)
    }

    private var containerIdentifier: String {
        guard let identifier else { return "" }
        return SampleID.FieldPart.container(identifier)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(isDisabled ? Color("middleGrey") : Color("darkGrey"))
                .accessibilityIdentifier(labelIdentifier)
            TextField(placeholder, text: $text)
                .accessibilityIdentifier(identifier ?? "")
                .font(.system(.subheadline, design: .monospaced))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .disabled(isDisabled)
                .padding(10)
                .background(isDisabled ? Color("lightGrey").opacity(0.5) : Color("lightGrey"))
                .foregroundStyle(isDisabled ? Color("middleGrey") : Color("violet"))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color("middleGrey"), lineWidth: 1)
                )
        }
        // Without `.contain`, SwiftUI hands the stack's identifier down to the
        // caption and the field, overwriting their own.
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(containerIdentifier)
    }
}
