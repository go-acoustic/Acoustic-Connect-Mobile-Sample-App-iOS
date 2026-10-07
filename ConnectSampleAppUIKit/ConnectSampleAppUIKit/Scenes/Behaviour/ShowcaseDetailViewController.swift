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

/// The screen the Showcase's "Screen views" card navigates to.
///
/// Arriving here is the demo: the screen view has just been logged with this
/// screen's name and the previous screen as referrer. Nothing here calls the SDK
/// beyond naming the screen.
///
/// "Push another" stacks a second copy with a different name, so a reader can
/// see the referrer chain advance and confirm the leaf screen's name is what
/// gets logged rather than a joined path. The chain is capped at
/// ``BehaviourRoute/maxShowcaseDepth``: a few levels show the behaviour, and an
/// unbounded stack is only a way to run out of memory.
@MainActor
final class ShowcaseDetailViewController: CardListViewController {

    private let name: String
    private let depth: Int

    override var screenName: String? {
        BehaviourRoute.showcaseDetail(name: name, depth: depth).screenName
    }

    private var isAtCap: Bool { depth >= BehaviourRoute.maxShowcaseDepth }

    init(name: String, depth: Int) {
        self.name = name
        self.depth = depth
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setCards([loggedCard(), chainCard()])
    }

    // MARK: - Cards

    private func loggedCard() -> CardView {
        let logged = makeBodyLabel(name)
        logged.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        logged.textColor = UIColor(named: "violet")

        return CardView(
            title: "Screen view logged",
            arrangedSubviews: [
                makeBodyLabel("Opening this screen logged a screen view named:"),
                logged,
                makeBodyLabel("""
                    The referrer is the screen you navigated from. Going back logs \
                    the previous screen again, with this one as its referrer.
                    """)
            ]
        )
    }

    private func chainCard() -> CardView {
        let pushButton = makePrimaryButton(
            title: isAtCap ? "Chain limit reached" : "Push another",
            identifier: SampleID.Showcase.pushDetail,
            action: UIAction { [weak self] _ in
                self?.pushNext()
            }
        )
        pushButton.isEnabled = !isAtCap

        let backButton = makeSecondaryButton(
            title: "Back",
            identifier: SampleID.Showcase.back,
            action: UIAction { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
        )

        return CardView(
            title: "Referrer chain",
            arrangedSubviews: [
                makeBodyLabel("""
                    Push another detail screen to see the chain advance by one, then \
                    pop back through it. Depth \(depth) of \
                    \(BehaviourRoute.maxShowcaseDepth).
                    """),
                pushButton,
                backButton
            ]
        )
    }

    // MARK: - Navigation

    private func pushNext() {
        guard !isAtCap else { return }
        let nextName = "Showcase detail \(depth + 1)"
        let next = ShowcaseDetailViewController(name: nextName, depth: depth + 1)
        next.title = BehaviourRoute.showcaseDetail(name: nextName, depth: depth + 1).title
        navigationController?.pushViewController(next, animated: true)
    }
}
