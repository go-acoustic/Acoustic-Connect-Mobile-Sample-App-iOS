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

/// Card shell for one fix under verification.
///
/// Prints what to do and what a fixed build produces, so the tester does not
/// have to hold the expectation in their head — and, when the fix has no
/// published artifact yet, says so in a banner.
///
/// That banner is the point of this view. A card whose fix has not shipped
/// still runs and still looks healthy; without the warning, "no error" reads as
/// a pass when it is really a baseline.
struct ScenarioCardView<Content: View>: View {

    let scenario: Scenario

    @ViewBuilder var content: () -> Content

    init(scenario: Scenario, @ViewBuilder content: @escaping () -> Content = { EmptyView() }) {
        self.scenario = scenario
        self.content = content
    }

    var body: some View {
        DemoCard(title: scenario.title) {
            VStack(alignment: .leading, spacing: 10) {
                metaRow

                if let blockedBy = scenario.blockedBy {
                    blockedBanner(blockedBy)
                }

                labelled("Do", scenario.action)
                labelled("Expect", scenario.expected)

                content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Pieces

    private var metaRow: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(scenario.key)
                .font(.system(.caption2, design: .monospaced).bold())
                .foregroundStyle(Color("periwinkle"))
            Spacer(minLength: 8)
            Text("\(scenario.channel.label) · \(scenario.platform.rawValue)")
                .font(.caption2)
                .foregroundStyle(Color("darkGrey"))
                .multilineTextAlignment(.trailing)
        }
    }

    private func blockedBanner(_ blockedBy: String) -> some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(Color("periwinkle"))
                .frame(width: 3)
            VStack(alignment: .leading, spacing: 4) {
                Text("Baseline only — fix not published")
                    .font(.caption.bold())
                Text(blockedBy)
                    .font(.caption)
            }
            .foregroundStyle(Color("violet"))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .background(Color("lightGrey"))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .fixedSize(horizontal: false, vertical: true)
    }

    private func labelled(_ label: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.caption2.bold())
                .kerning(1)
                .foregroundStyle(Color("darkGrey"))
            Text(body)
                .font(.subheadline)
                .foregroundStyle(Color("darkGrey"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            ScenarioCardView(scenario: Scenarios.customEventValueTypes)
            ScenarioCardView(scenario: Scenarios.screenViewReferrer)
        }
        .padding()
    }
    .background(Color("background"))
}
