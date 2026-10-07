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

/// The pushed screen for one screen-name case, matching `ScreenViewCaseView` in
/// the SwiftUI sample. Arriving here is the event under test: the screen names
/// itself with the case's name in `viewWillAppear`, so a type-2 message with
/// that exact name is already on its way to the collector.
@MainActor
final class ScreenViewCaseViewController: CardListViewController {

    private let screenViewCase: ScreenViewCase
    private let reloggedLabel = makeResultLabel(identifier: SampleID.ScreenViews.caseRelogResult)

    override var screenName: String? { BehaviourRoute.screenViewCase(screenViewCase).screenName }

    init(screenViewCase: ScreenViewCase) {
        self.screenViewCase = screenViewCase
        super.init(nibName: nil, bundle: nil)
        title = BehaviourRoute.screenViewCase(screenViewCase).title
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setCards([loggedNameCard(), expectedCard(), repeatCard()])
    }

    // MARK: - Cards

    private func loggedNameCard() -> CardView {
        let name = makeBodyLabel(ScreenViewCases.describe(screenViewCase.name))
        name.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
        name.textColor = UIColor(named: "violet")
        return CardView(
            title: "Logged screen name",
            arrangedSubviews: [
                name,
                makeBodyLabel(
                    "\(screenViewCase.name?.utf16.count ?? 0) characters · this screen's page name",
                    style: .caption2
                ),
                makeBodyLabel(screenViewCase.probes)
            ]
        )
    }

    private func expectedCard() -> CardView {
        CardView(
            title: "Expected result",
            arrangedSubviews: [
                makeBodyLabel("""
                    The type-2 message should carry screenview.name exactly as shown \
                    above, and the inferred pageView signal should carry the same string \
                    as signalContent.url — valid, not in the invalid-signal topic.
                    """)
            ]
        )
    }

    private func repeatCard() -> CardView {
        var rows: [UIView] = [
            makeBodyLabel("""
                Re-send the same name through the direct call, to compare the \
                navigation-driven message against an explicit one.
                """),
            makePrimaryButton(
                title: "Log this name directly",
                identifier: SampleID.ScreenViews.caseRelog,
                action: UIAction { [weak self] _ in self?.relog() }
            ),
            reloggedLabel
        ]
        if let next = ScreenViewCases.next(after: screenViewCase) {
            rows.append(
                makeSecondaryButton(
                    title: "Push deeper — \(next.label)",
                    identifier: SampleID.ScreenViews.casePushNext,
                    action: UIAction { [weak self] _ in
                        self?.navigationController?.pushViewController(
                            ScreenViewCaseViewController(screenViewCase: next),
                            animated: true
                        )
                    }
                )
            )
        }
        return CardView(title: "Repeat", arrangedSubviews: rows)
    }

    // MARK: - Actions

    private func relog() {
        let queued = BehaviourStore.shared.logScreenViewDirect(
            name: screenViewCase.name,
            referrer: BehaviourRoute.screenViews.screenName
        )
        reloggedLabel.text = "\(queued ? "✓" : "✗") re-logged directly"
        reloggedLabel.isHidden = false
    }
}
