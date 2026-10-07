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

/// Dialog capture demo, matching `DialogCard` in the SwiftUI sample. There is
/// no SDK call here: the alert is presented exactly as any app presents one,
/// and the SDK logs it on its own.
@MainActor
final class DialogCardBody: UIStackView {

    private weak var presenter: UIViewController?

    private let resultLabel = makeResultLabel(identifier: SampleID.Showcase.dialogResult)

    /// The body in its card.
    ///
    /// - Parameter presenter: The view controller that presents the alert.
    static func makeCard(presenter: UIViewController) -> CardView {
        CardView(title: "Dialogs", arrangedSubviews: [DialogCardBody(presenter: presenter)])
    }

    init(presenter: UIViewController) {
        self.presenter = presenter
        super.init(frame: .zero)

        axis = .vertical
        spacing = 10

        addArrangedSubview(makeBodyLabel("""
            Opens a standard alert. The SDK logs the alert and the button \
            pressed, with no change to how the alert is presented.
            """))
        addArrangedSubview(
            makePrimaryButton(
                title: "Show a dialog",
                identifier: SampleID.Showcase.dialog,
                action: UIAction { [weak self] _ in
                    self?.showDialog()
                }
            )
        )
        addArrangedSubview(resultLabel)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func showDialog() {
        let alert = UIAlertController(
            title: "Showcase dialog",
            message: "Pick a button — each press is logged.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.show("Cancel pressed")
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.show("OK pressed")
        })
        presenter?.present(alert, animated: true)
    }

    private func show(_ result: String) {
        resultLabel.text = result
        resultLabel.isHidden = false
    }
}
