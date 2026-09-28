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

/// Identity tab. Drives `IdentityStore`, the same type the SwiftUI sample's
/// Identity tab drives — this target compiles those files from the push
/// sample rather than copying them.
@MainActor
final class IdentityViewController: CardListViewController {

    override var screenName: String? { "Identity" }

    private let store = IdentityStore.shared
    private var cancellables = Set<AnyCancellable>()

    private let nameField = UITextField()
    private let valueField = UITextField()
    private let resultLabel = makeBodyLabel("")
    private lazy var resultCard = CardView(title: "Last Result", arrangedSubviews: [resultLabel])

    override func viewDidLoad() {
        super.viewDidLoad()
        setCards([resultCard, inputCard()])
        observeStore()
    }

    // MARK: - Cards

    private func inputCard() -> CardView {
        let loggedInButton = makePrimaryButton(
            title: "Log Logged In With Email",
            identifier: SampleID.Identity.sendIdentitySignal,
            action: UIAction { [weak self] _ in
                self?.log { store, name, value in
                    store.logUserLoggedIn(identifierName: name, identifierValue: value)
                }
            }
        )
        let registeredButton = makePrimaryButton(
            title: "Log Account Registered With Email",
            identifier: SampleID.Identity.sendAccountRegisteredSignal,
            action: UIAction { [weak self] _ in
                self?.log { store, name, value in
                    store.logUserRegistered(identifierName: name, identifierValue: value)
                }
            }
        )

        return CardView(
            title: "Log Identity",
            arrangedSubviews: [
                makeLabeledTextField(
                    label: "Identifier Name",
                    placeholder: "Email Address",
                    field: nameField,
                    identifier: SampleID.Identity.identifierName
                ),
                makeLabeledTextField(
                    label: "Identifier Value",
                    placeholder: "user@example.com",
                    field: valueField,
                    identifier: SampleID.Identity.identifierValue
                ),
                loggedInButton,
                registeredButton
            ]
        )
    }

    // MARK: - Actions

    private func log(_ body: (IdentityStore, String, String) -> Void) {
        body(store, nameField.text ?? "", valueField.text ?? "")
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
