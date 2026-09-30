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

/// Screen Views screen — the verification surface for the `pageView` signal
/// the platform infers from every screen view. Matches `ScreenViewsView` in the
/// SwiftUI sample.
///
/// Drilling into a case is a real navigation: the pushed screen names itself in
/// `viewWillAppear`, the way a customer's app does.
@MainActor
final class ScreenViewsViewController: CardListViewController {

    override var screenName: String? { BehaviourRoute.screenViews.screenName }

    override func viewDidLoad() {
        super.viewDidLoad()
        setCards([howToVerifyCard(), navigateCard(), DirectScreenViewCardBody.makeCard()])
    }

    // MARK: - Cards

    private func howToVerifyCard() -> CardView {
        CardView(
            title: "How this is verified",
            arrangedSubviews: [
                makeBodyLabel("""
                    Every screen view sends a type-2 message carrying the screen name. \
                    The platform derives a pageView signal from it; because a mobile \
                    screen has no URL, the server-side rule falls back to that name for \
                    the signal's url.
                    """),
                makeBodyLabel("""
                    So each button below is one test of that fallback. Drive them, then \
                    check the subscription's inferred pageView definition — valid count \
                    should rise and the Missing required field: [url] records should stop.
                    """),
                makeHintBox("""
                    Do not press the Showcase or Verification Log Signal buttons during \
                    a run. They send an explicit pageview signal, and inference stands \
                    down for a subscription that sends its own — which would read as a \
                    pass when it is really a suppression.
                    """)
            ]
        )
    }

    private func navigateCard() -> CardView {
        var rows: [UIView] = [
            makeBodyLabel("""
                Pushes a screen that names itself with setCurrentScreen(pageName:) as \
                it appears. Navigate back and re-enter to produce repeat views.
                """)
        ]
        for screenViewCase in ScreenViewCases.navigation {
            let logs = makeBodyLabel("logs: \(ScreenViewCases.describe(screenViewCase.name))", style: .caption2)
            logs.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
            logs.textColor = UIColor(named: "violet")
            let block = UIStackView(arrangedSubviews: [
                makeSecondaryButton(
                    title: screenViewCase.label,
                    identifier: SampleID.ScreenViews.navigateButton(screenViewCase.id),
                    action: UIAction { [weak self] _ in self?.push(screenViewCase) }
                ),
                logs
            ])
            block.axis = .vertical
            block.spacing = 6
            rows.append(block)
        }
        return CardView(title: "Navigate — real integration path", arrangedSubviews: rows)
    }

    // MARK: - Navigation

    private func push(_ screenViewCase: ScreenViewCase) {
        navigationController?.pushViewController(ScreenViewCaseViewController(screenViewCase: screenViewCase), animated: true)
    }
}
