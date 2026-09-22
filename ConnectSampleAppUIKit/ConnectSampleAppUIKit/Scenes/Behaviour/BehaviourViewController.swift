//
// Copyright (C) 2026 Acoustic, L.P. All rights reserved.
//
// Licensed under the Acoustic License (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy
// at https://www.acoustic.com/licenses/acoustic-license
//
// Sample app provided "as is", without warranty of any kind.
//

import Combine
import UIKit

/// Behaviour tab. Drives `BehaviourStore`, the same type the SwiftUI sample's
/// Behaviour tab drives.
@MainActor
final class BehaviourViewController: CardListViewController {

    private let store = BehaviourStore.shared
    private var cancellables = Set<AnyCancellable>()

    private let resultLabel = makeBodyLabel("")
    private lazy var resultCard = CardView(title: "Last Result", arrangedSubviews: [resultLabel])

    override func viewDidLoad() {
        super.viewDidLoad()
        setCards([resultCard, automaticCaptureCard(), customEventCard()])
        observeStore()
    }

    // MARK: - Cards

    private func automaticCaptureCard() -> CardView {
        CardView(
            title: "Captured Automatically",
            arrangedSubviews: [
                makeBodyLabel("""
                    Enabling the SDK is enough to capture screen views, taps and text \
                    entry — no calls needed. Moving between these tabs already logs \
                    screen views.
                    """),
                makeBodyLabel(
                    "iOS posts to the collector when the app is backgrounded, so background the app and read the messages there.",
                    style: .caption1
                )
            ]
        )
    }

    private func customEventCard() -> CardView {
        let button = makePrimaryButton(
            title: "Log Custom Event",
            action: UIAction { [weak self] _ in
                self?.store.logCustomEvent()
            }
        )

        return CardView(
            title: "Custom Event",
            arrangedSubviews: [
                makeBodyLabel("""
                    logEvent(name:values:) sends a named event with a flat map of \
                    string, number and boolean values. Read it under customEvent in \
                    the posted message.
                    """),
                button
            ]
        )
    }

    // MARK: - Store

    private func observeStore() {
        store.$lastResult
            .sink { [weak self] result in
                self?.resultLabel.text = result
                self?.resultCard.isHidden = result == nil
            }
            .store(in: &cancellables)
    }
}
