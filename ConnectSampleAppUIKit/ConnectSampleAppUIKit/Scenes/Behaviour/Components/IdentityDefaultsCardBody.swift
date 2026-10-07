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

/// Identity defaults, the contrast pair for the `identity-login-method-default`
/// scenario, matching `IdentityDefaultsCard` in the SwiftUI sample.
///
/// The first button omits both optional arguments, so the native SDK supplies
/// its defaults — `signalType: pageView`, no parameters. The second is the
/// explicit `accountRegistered` case.
@MainActor
final class IdentityDefaultsCardBody: UIStackView {

    private let store = BehaviourStore.shared
    private var cancellables = Set<AnyCancellable>()

    private let resultLabel = makeResultLabel(identifier: SampleID.Verification.identityDefaultsResult)

    /// The body in its scenario card.
    static func makeCard() -> CardView {
        makeScenarioCard(scenario: Scenarios.identityLoginMethodDefault, body: [IdentityDefaultsCardBody()])
    }

    init() {
        super.init(frame: .zero)

        axis = .vertical
        spacing = 10

        addArrangedSubview(
            makePrimaryButton(
                title: "Log identity — omit both optional args",
                identifier: SampleID.Verification.identityDefaulted,
                action: UIAction { [weak self] _ in
                    self?.store.logIdentityDefaulted()
                }
            )
        )
        addArrangedSubview(
            makeSecondaryButton(
                title: "Log accountRegistered — explicit",
                identifier: SampleID.Verification.identityExplicit,
                action: UIAction { [weak self] _ in
                    self?.store.logIdentityExplicit()
                }
            )
        )
        addArrangedSubview(resultLabel)

        observeStore()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func observeStore() {
        store.$identityDefaultsResult
            .sink { [weak self] result in
                self?.resultLabel.text = result
                self?.resultLabel.isHidden = result == nil
            }
            .store(in: &cancellables)
    }
}
