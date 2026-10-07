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

/// Runtime capture control, matching `CaptureControlCard` in the SwiftUI
/// sample. Shared by the Showcase and the Verification screen.
///
/// Tap Disable, move between screens, then Re-enable. Nothing from the disabled
/// stretch should reach the collector. Watch the posts after re-enabling as
/// well as during: a build that keeps recording while disabled and posts the
/// backlog on re-enable passes a check that only watches the disabled stretch.
@MainActor
final class CaptureControlCardBody: UIStackView {

    private let store = BehaviourStore.shared
    private var cancellables = Set<AnyCancellable>()

    private let stateLabel = makeResultLabel(identifier: SampleID.Showcase.captureState)

    /// The body in its card.
    static func makeCard() -> CardView {
        CardView(title: "Runtime capture control", arrangedSubviews: [CaptureControlCardBody()])
    }

    init() {
        super.init(frame: .zero)

        axis = .vertical
        spacing = 10

        addArrangedSubview(makeBodyLabel("""
            disable() is meant to stop capture. Confirm it on the build in front \
            of you rather than assuming: tap Disable, navigate a few screens, then \
            Re-enable. Nothing from the disabled stretch should reach the \
            collector — not while disabled, and not after re-enabling either.
            """))
        addArrangedSubview(
            makePrimaryButton(
                title: "Disable SDK",
                identifier: SampleID.Showcase.captureDisable,
                action: UIAction { [weak self] _ in
                    self?.store.disableCapture()
                }
            )
        )
        addArrangedSubview(
            makePrimaryButton(
                title: "Re-enable SDK",
                identifier: SampleID.Showcase.captureEnable,
                action: UIAction { [weak self] _ in
                    self?.store.enableCapture()
                }
            )
        )
        addArrangedSubview(stateLabel)

        observeStore()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func observeStore() {
        store.$captureState
            .sink { [weak self] state in
                self?.stateLabel.text = state
                self?.stateLabel.isHidden = state == nil
            }
            .store(in: &cancellables)
    }
}
