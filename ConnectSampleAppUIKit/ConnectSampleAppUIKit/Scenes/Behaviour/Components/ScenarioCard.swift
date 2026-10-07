//
// Copyright (C) 2026 Acoustic, L.P. All rights reserved.
//
// Licensed under the Acoustic License (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy
// at https://www.acoustic.com/licenses/acoustic-license
//
// Sample app provided "as is", without warranty of any kind.
//

import UIKit

/// Builds the card for one fix under verification, matching `ScenarioCardView`
/// in the SwiftUI sample.
///
/// Prints what to do and what a fixed build produces, so the tester does not
/// have to hold the expectation in their head — and, when the fix has no
/// published artifact yet, says so in a banner.
///
/// That banner is the point of this card. A card whose fix has not shipped still
/// runs and still looks healthy; without the warning, "no error" reads as a pass
/// when it is really a baseline.
///
/// - Parameters:
///   - scenario: The scenario to render.
///   - body: The scenario's interactive controls, where it has any.
/// - Returns: The card.
@MainActor
func makeScenarioCard(scenario: Scenario, body: [UIView] = []) -> CardView {
    var rows: [UIView] = [metaRow(for: scenario)]

    if let blockedBy = scenario.blockedBy {
        rows.append(blockedBanner(blockedBy))
    }

    rows.append(sectionLabel("Do"))
    rows.append(makeBodyLabel(scenario.action))
    rows.append(sectionLabel("Expect"))
    rows.append(makeBodyLabel(scenario.expected))
    rows.append(contentsOf: body)

    return CardView(title: scenario.title, arrangedSubviews: rows)
}

// MARK: - Pieces

@MainActor
private func metaRow(for scenario: Scenario) -> UIView {
    let key = UILabel()
    key.text = scenario.key
    key.font = .monospacedSystemFont(ofSize: 11, weight: .bold)
    key.textColor = UIColor(named: "periwinkle")
    key.numberOfLines = 0

    let channel = UILabel()
    channel.text = "\(scenario.channel.label) · \(scenario.platform.rawValue)"
    channel.font = .preferredFont(forTextStyle: .caption2)
    channel.textColor = UIColor(named: "darkGrey")
    channel.textAlignment = .right
    channel.numberOfLines = 0
    channel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    let row = UIStackView(arrangedSubviews: [key, channel])
    row.axis = .horizontal
    row.alignment = .firstBaseline
    row.spacing = 8
    return row
}

@MainActor
private func blockedBanner(_ blockedBy: String) -> UIView {
    let title = UILabel()
    title.text = "Baseline only — fix not published"
    title.font = .preferredFont(forTextStyle: .caption1).bold()
    title.textColor = UIColor(named: "violet")
    title.numberOfLines = 0

    let detail = makeBodyLabel(blockedBy, style: .caption1)
    detail.textColor = UIColor(named: "violet")

    let text = UIStackView(arrangedSubviews: [title, detail])
    text.axis = .vertical
    text.spacing = 4

    let rule = UIView()
    rule.backgroundColor = UIColor(named: "periwinkle")
    rule.widthAnchor.constraint(equalToConstant: 3).isActive = true

    let row = UIStackView(arrangedSubviews: [rule, text])
    row.axis = .horizontal
    row.spacing = 10
    row.alignment = .fill
    row.isLayoutMarginsRelativeArrangement = true
    row.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    row.backgroundColor = UIColor(named: "lightGrey")
    row.layer.cornerRadius = 8
    return row
}

@MainActor
private func sectionLabel(_ text: String) -> UILabel {
    let label = UILabel()
    label.attributedText = NSAttributedString(
        string: text.uppercased(),
        attributes: [.kern: 1]
    )
    label.font = .preferredFont(forTextStyle: .caption2).bold()
    label.textColor = UIColor(named: "darkGrey")
    return label
}

private extension UIFont {

    /// The bold face of this font at the same size, for the card's small labels.
    func bold() -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(.traitBold) else { return self }
        return UIFont(descriptor: descriptor, size: 0)
    }
}
