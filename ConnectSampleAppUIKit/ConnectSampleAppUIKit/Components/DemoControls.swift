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

/// Periwinkle-filled button, matching `PrimaryButtonStyle` in the SwiftUI sample.
///
/// - Parameters:
///   - title: The button's label.
///   - identifier: Accessibility identifier from ``SampleID``, so the e2e suite
///     addresses this control by the same name on every platform.
///   - action: What the button does.
/// - Returns: The configured button.
func makePrimaryButton(title: String, identifier: String? = nil, action: UIAction) -> UIButton {
    makeButton(title: title, identifier: identifier, action: action, fill: "periwinkle")
}

/// Dark-grey button, matching `SecondaryButtonStyle` in the SwiftUI sample.
///
/// - Parameters:
///   - title: The button's label.
///   - identifier: Accessibility identifier from ``SampleID``.
///   - action: What the button does.
/// - Returns: The configured button.
func makeSecondaryButton(title: String, identifier: String? = nil, action: UIAction) -> UIButton {
    makeButton(title: title, identifier: identifier, action: action, fill: "darkGrey")
}

private func makeButton(
    title: String,
    identifier: String?,
    action: UIAction,
    fill: String
) -> UIButton {
    var configuration = UIButton.Configuration.filled()
    configuration.title = title
    configuration.baseBackgroundColor = UIColor(named: fill)
    configuration.baseForegroundColor = .white
    configuration.cornerStyle = .medium
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)

    let button = UIButton(configuration: configuration, primaryAction: action)
    button.setContentHuggingPriority(.defaultLow, for: .horizontal)
    button.accessibilityIdentifier = identifier
    return button
}

/// Body-copy label in secondary grey.
///
/// - Parameters:
///   - text: The label's text.
///   - style: The text style. Defaults to `.subheadline`.
///   - identifier: Accessibility identifier from ``SampleID``, for a label the
///     e2e suite reads a result from.
/// - Returns: The configured label.
func makeBodyLabel(
    _ text: String,
    style: UIFont.TextStyle = .subheadline,
    identifier: String? = nil
) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = .preferredFont(forTextStyle: style)
    label.textColor = UIColor(named: "darkGrey")
    label.numberOfLines = 0
    label.accessibilityIdentifier = identifier
    return label
}

/// Caption label above a text field, plus the field itself, matching
/// `DemoTextField` in the SwiftUI sample.
///
/// - Parameters:
///   - label: The caption above the field.
///   - placeholder: The field's placeholder.
///   - field: The field to configure.
///   - identifier: Accessibility identifier for the field. The caption and the
///     stack take the `_label` and `_container` suffixes React Native's
///     `DemoTextField` adds, so one page object addresses the same three
///     elements on every platform.
/// - Returns: The stack holding caption and field.
func makeLabeledTextField(
    label: String,
    placeholder: String,
    field: UITextField,
    identifier: String? = nil
) -> UIStackView {
    let caption = UILabel()
    caption.text = label
    caption.font = .preferredFont(forTextStyle: .caption1)
    caption.textColor = UIColor(named: "darkGrey")
    caption.accessibilityIdentifier = identifier.map(SampleID.FieldPart.label)

    field.placeholder = placeholder
    field.borderStyle = .none
    field.backgroundColor = UIColor(named: "lightGrey")
    field.layer.cornerRadius = 8
    field.autocorrectionType = .no
    field.autocapitalizationType = .none
    field.textColor = UIColor(named: "violet")
    field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
    field.leftViewMode = .always
    field.heightAnchor.constraint(equalToConstant: 44).isActive = true
    field.accessibilityIdentifier = identifier

    let stack = UIStackView(arrangedSubviews: [caption, field])
    stack.axis = .vertical
    stack.spacing = 4
    stack.accessibilityIdentifier = identifier.map(SampleID.FieldPart.container)
    return stack
}

/// Monospaced violet label for the line a card prints after it has been
/// driven, matching `ResultText` in the SwiftUI sample. Starts hidden and
/// empty; set its text once there is a result.
///
/// - Parameter identifier: Accessibility identifier from ``SampleID``, so the
///   e2e suite can read the result without matching on layout.
/// - Returns: The configured label.
func makeResultLabel(identifier: String) -> UILabel {
    let label = makeBodyLabel("", style: .caption2, identifier: identifier)
    label.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
    label.textColor = UIColor(named: "violet")
    label.isHidden = true
    return label
}

/// Light-grey rounded box around a view, for payloads, hints and results.
///
/// - Parameter content: The view to inset.
/// - Returns: The box, with `content` inset 10 points on every side.
func makeInsetBox(containing content: UIView) -> UIView {
    let box = UIView()
    box.backgroundColor = UIColor(named: "lightGrey")
    box.layer.cornerRadius = 8
    content.translatesAutoresizingMaskIntoConstraints = false
    box.addSubview(content)
    NSLayoutConstraint.activate([
        content.topAnchor.constraint(equalTo: box.topAnchor, constant: 10),
        content.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 10),
        content.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -10),
        content.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -10)
    ])
    return box
}
