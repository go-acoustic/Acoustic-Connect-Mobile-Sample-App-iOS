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

/// `logEvent` demo body, shared by the Showcase — inside a plain ``CardView`` —
/// and the Verification screen, inside a scenario card.
///
/// The body is the demo and the frame is per screen, so the two screens cannot
/// drift into demonstrating the same call two different ways. Mirrors
/// `CustomEventBody` in the SwiftUI sample.
@MainActor
final class CustomEventBodyView: UIStackView {

    private let store = BehaviourStore.shared
    private var cancellables = Set<AnyCancellable>()

    private let resultLabel = makeBodyLabel(
        "",
        style: .caption2,
        identifier: SampleID.Showcase.customEventResult
    )

    init() {
        super.init(frame: .zero)

        axis = .vertical
        spacing = 10

        addArrangedSubview(payloadView())
        addArrangedSubview(
            makePrimaryButton(
                title: "Send custom event",
                identifier: SampleID.Showcase.sendCustomEvent,
                action: UIAction { [weak self] _ in
                    self?.store.logCustomEvent()
                }
            )
        )

        resultLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        resultLabel.textColor = UIColor(named: "violet")
        addArrangedSubview(resultLabel)

        observeStore()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Pieces

    private func payloadView() -> UIView {
        let label = makeBodyLabel(BehaviourStore.customEventPayloadDisplay, style: .caption2)
        label.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        label.textColor = UIColor(named: "violet")

        let container = UIView()
        container.backgroundColor = UIColor(named: "lightGrey")
        container.layer.cornerRadius = 8
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10)
        ])
        return container
    }

    // MARK: - Store

    private func observeStore() {
        store.$customEventResult
            .sink { [weak self] result in
                self?.resultLabel.text = result
                self?.resultLabel.isHidden = result == nil
            }
            .store(in: &cancellables)
    }
}
