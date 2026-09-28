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

/// Scrolling column of cards on the sample's background colour — the UIKit
/// equivalent of the `ScrollView { VStack { … } }` the SwiftUI sample uses.
@MainActor
class CardListViewController: UIViewController {

    private let cardStack = UIStackView()

    /// The name logged for this screen's screen view.
    ///
    /// iOS otherwise names a screen view after the view controller's class,
    /// which would give every card screen here the same name. Subclasses
    /// override this with their route's ``BehaviourRoute/screenName``; a screen
    /// that returns `nil` keeps the inferred name.
    var screenName: String? { nil }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let screenName {
            SampleScreenNaming.nameCurrentScreen(screenName)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "background")

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)

        cardStack.axis = .vertical
        cardStack.spacing = 20
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(cardStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            cardStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            cardStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32),
            cardStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            cardStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16)
        ])
    }

    /// Replaces the cards on screen, in order.
    func setCards(_ cards: [UIView]) {
        cardStack.arrangedSubviews.forEach {
            cardStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        cards.forEach { cardStack.addArrangedSubview($0) }
    }
}
