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

/// Session-replay reference for a full-screen modal, matching
/// `ReplayModalCard` in the SwiftUI sample.
///
/// A modal is presented by its own view controller rather than pushed onto the
/// navigation stack, so session replay has to resolve its controls outside the
/// stack the rest of the app lives in.
@MainActor
final class ReplayModalCardBody: UIStackView {

    private weak var presenter: UIViewController?

    /// The body in its card.
    ///
    /// - Parameter presenter: The view controller that presents the modal. Its
    ///   `viewWillAppear` runs again when the modal is dismissed, which is what
    ///   re-names the screen the user returns to.
    static func makeCard(presenter: UIViewController) -> CardView {
        CardView(title: "Modal (opaque)", arrangedSubviews: [ReplayModalCardBody(presenter: presenter)])
    }

    init(presenter: UIViewController) {
        self.presenter = presenter
        super.init(frame: .zero)

        axis = .vertical
        spacing = 10

        addArrangedSubview(makeBodyLabel("""
            Opens a full-screen modal. Every element inside it should be \
            selectable in session replay, not just visible in the screenshot.
            """))
        addArrangedSubview(
            makePrimaryButton(
                title: "Open modal",
                identifier: SampleID.ReplayModal.openOpaque,
                action: UIAction { [weak self] _ in
                    self?.openModal()
                }
            )
        )
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func openModal() {
        let modal = ReplayModalViewController()
        modal.modalPresentationStyle = .fullScreen
        presenter?.present(modal, animated: true)
    }
}

/// The modal itself. The controls are deliberately varied — text, a text
/// field, two buttons and a status line — so a replay reviewer can confirm each
/// one is individually inspectable rather than just seeing a correct-looking
/// screenshot.
///
/// The status line echoes the note and the action count, so an interaction that
/// never registered can be told apart from one the SDK failed to capture.
@MainActor
private final class ReplayModalViewController: UIViewController {

    private let noteField = UITextField()
    private let statusLabel = makeBodyLabel("", style: .caption1, identifier: SampleID.ReplayModal.result)
    private var actionCount = 0

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SampleScreenNaming.nameCurrentScreen(BehaviourRoute.replayModalScreenName)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "background")

        let title = UILabel()
        title.text = "Modal content"
        title.font = .preferredFont(forTextStyle: .headline)
        title.textColor = UIColor(named: "violet")

        noteField.addAction(
            UIAction { [weak self] _ in self?.showStatus() },
            for: .editingChanged
        )
        statusLabel.textColor = UIColor(named: "violet")

        let sheet = UIStackView(arrangedSubviews: [
            title,
            makeBodyLabel("""
                Text, a field and buttons — each should appear as its own control \
                in the captured layout.
                """),
            makeLabeledTextField(
                label: "Note",
                placeholder: "Type to check text capture",
                field: noteField,
                identifier: SampleID.ReplayModal.note
            ),
            makePrimaryButton(
                title: "Primary action",
                identifier: SampleID.ReplayModal.action,
                action: UIAction { [weak self] _ in
                    self?.actionCount += 1
                    self?.showStatus()
                }
            ),
            makeSecondaryButton(
                title: "Close",
                identifier: SampleID.ReplayModal.close,
                action: UIAction { [weak self] _ in
                    self?.dismiss(animated: true)
                }
            ),
            statusLabel
        ])
        sheet.axis = .vertical
        sheet.spacing = 14
        sheet.translatesAutoresizingMaskIntoConstraints = false

        let surface = UIView()
        surface.backgroundColor = .white
        surface.layer.cornerRadius = 14
        surface.translatesAutoresizingMaskIntoConstraints = false
        surface.addSubview(sheet)
        view.addSubview(surface)

        NSLayoutConstraint.activate([
            sheet.topAnchor.constraint(equalTo: surface.topAnchor, constant: 20),
            sheet.leadingAnchor.constraint(equalTo: surface.leadingAnchor, constant: 20),
            sheet.trailingAnchor.constraint(equalTo: surface.trailingAnchor, constant: -20),
            sheet.bottomAnchor.constraint(equalTo: surface.bottomAnchor, constant: -20),

            surface.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            surface.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            surface.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        showStatus()
    }

    private func showStatus() {
        let note = noteField.text ?? ""
        statusLabel.text = "Note: \(note.isEmpty ? "—" : note) · Primary action taps: \(actionCount)"
    }
}
