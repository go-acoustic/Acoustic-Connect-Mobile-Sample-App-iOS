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

/// `logSignal` card, matching `SignalCard` in the SwiftUI sample — the
/// on-device check that a nested signal payload reaches the collector with its
/// structure intact. Shared by the Showcase and the Verification screen.
///
/// The nested button sends an object plus an array of objects; the flat button
/// sends scalars only. Both payloads are defined in ``BehaviourStore/Signal``.
@MainActor
final class SignalCardBody: UIStackView {

    private let store = BehaviourStore.shared
    private var cancellables = Set<AnyCancellable>()

    private let resultLabel = makeResultLabel(identifier: SampleID.Showcase.signalResult)
    private lazy var resultBox = makeInsetBox(containing: resultLabel)

    /// The body in its card.
    static func makeCard() -> CardView {
        CardView(title: "Log Signal", arrangedSubviews: [SignalCardBody()])
    }

    init() {
        super.init(frame: .zero)

        axis = .vertical
        spacing = 10

        addArrangedSubview(makeBodyLabel("""
            Sends a signal through logSignal(_:level:). The nested payload \
            carries an object and an array of objects; the flat one is scalars \
            only. Compare the signal block in the posted type-21 message across \
            platforms.
            """))
        addArrangedSubview(
            makePrimaryButton(
                title: "Send Nested Signal",
                identifier: SampleID.Showcase.sendNestedSignal,
                action: UIAction { [weak self] _ in
                    self?.store.logSignal(.nested)
                }
            )
        )
        addArrangedSubview(
            makeSecondaryButton(
                title: "Send Flat Signal",
                identifier: SampleID.Showcase.sendFlatSignal,
                action: UIAction { [weak self] _ in
                    self?.store.logSignal(.flat)
                }
            )
        )
        // makeResultLabel returns a hidden label. This card shows and hides the
        // box around it instead, so the label itself has to be visible.
        resultLabel.isHidden = false
        addArrangedSubview(resultBox)

        observeStore()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func observeStore() {
        store.$signalResult
            .sink { [weak self] result in
                self?.resultLabel.text = result
                self?.resultBox.isHidden = result == nil
            }
            .store(in: &cancellables)
    }
}
