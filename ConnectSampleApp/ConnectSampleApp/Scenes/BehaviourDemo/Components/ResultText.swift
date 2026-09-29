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

/// The monospaced result line a card prints after it has been driven.
///
/// Each card's result carries an accessibility identifier, so the end-to-end
/// suite can read what the card did without matching on layout.
struct ResultText: View {

    let text: String
    let identifier: String

    var body: some View {
        Text(text)
            .font(.system(.caption2, design: .monospaced))
            .foregroundStyle(Color("violet"))
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier(identifier)
    }
}

/// Body copy under a card's title.
struct CardBodyText: View {

    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(Color("darkGrey"))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
