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
func makePrimaryButton(title: String, action: UIAction) -> UIButton {
    var configuration = UIButton.Configuration.filled()
    configuration.title = title
    configuration.baseBackgroundColor = UIColor(named: "periwinkle")
    configuration.baseForegroundColor = .white
    configuration.cornerStyle = .medium
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)

    let button = UIButton(configuration: configuration, primaryAction: action)
    button.setContentHuggingPriority(.defaultLow, for: .horizontal)
    return button
}

/// Body-copy label in secondary grey.
func makeBodyLabel(_ text: String, style: UIFont.TextStyle = .subheadline) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = .preferredFont(forTextStyle: style)
    label.textColor = UIColor(named: "darkGrey")
    label.numberOfLines = 0
    return label
}

/// Caption label above a text field, plus the field itself, matching
/// `DemoTextField` in the SwiftUI sample.
func makeLabeledTextField(label: String, placeholder: String, field: UITextField) -> UIStackView {
    let caption = UILabel()
    caption.text = label
    caption.font = .preferredFont(forTextStyle: .caption1)
    caption.textColor = UIColor(named: "darkGrey")

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

    let stack = UIStackView(arrangedSubviews: [caption, field])
    stack.axis = .vertical
    stack.spacing = 4
    return stack
}
