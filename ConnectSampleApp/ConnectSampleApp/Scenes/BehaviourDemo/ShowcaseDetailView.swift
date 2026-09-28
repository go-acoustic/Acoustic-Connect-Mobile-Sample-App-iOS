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

/// The screen the Showcase's "Screen views" card navigates to.
///
/// Arriving here is the demo: the screen view has just been logged with this
/// screen's name and the previous screen as referrer. Nothing here calls the
/// SDK beyond naming the screen.
///
/// "Push another" stacks a second copy with a different name, so a reader can
/// see the referrer chain advance and confirm the leaf screen's name is what
/// gets logged rather than a joined path. The chain is capped at
/// ``BehaviourRoute/maxShowcaseDepth``: a few levels show the behaviour, and an
/// unbounded stack is only a way to run out of memory.
struct ShowcaseDetailView: View {

    let name: String
    let depth: Int

    @Environment(\.dismiss) private var dismiss

    private var isAtCap: Bool { depth >= BehaviourRoute.maxShowcaseDepth }

    private var nextName: String { "Showcase detail \(depth + 1)" }

    private var nextRoute: BehaviourRoute {
        .showcaseDetail(name: nextName, depth: depth + 1)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                loggedCard
                chainCard
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("background"))
    }

    // MARK: - Cards

    private var loggedCard: some View {
        DemoCard(title: "Screen view logged") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Opening this screen logged a screen view named:")
                    .font(.subheadline)
                    .foregroundStyle(Color("darkGrey"))
                Text(name)
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundStyle(Color("violet"))
                Text("""
                    The referrer is the screen you navigated from. Going back logs \
                    the previous screen again, with this one as its referrer.
                    """)
                    .font(.subheadline)
                    .foregroundStyle(Color("darkGrey"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var chainCard: some View {
        DemoCard(title: "Referrer chain") {
            VStack(alignment: .leading, spacing: 10) {
                Text("""
                    Push another detail screen to see the chain advance by one, then \
                    pop back through it. Depth \(depth) of \
                    \(BehaviourRoute.maxShowcaseDepth).
                    """)
                    .font(.subheadline)
                    .foregroundStyle(Color("darkGrey"))
                    .frame(maxWidth: .infinity, alignment: .leading)

                NavigationLink(
                    destination: nextRoute.screen(
                        ShowcaseDetailView(name: nextName, depth: depth + 1)
                    )
                ) {
                    Text(isAtCap ? "Chain limit reached" : "Push another")
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isAtCap)
                .accessibilityIdentifier(SampleID.Showcase.pushDetail)

                Button("Back") {
                    dismiss()
                }
                .buttonStyle(SecondaryButtonStyle())
                .accessibilityIdentifier(SampleID.Showcase.back)
            }
        }
    }
}

#Preview {
    NavigationView {
        ShowcaseDetailView(name: "Showcase detail", depth: 1)
    }
}
