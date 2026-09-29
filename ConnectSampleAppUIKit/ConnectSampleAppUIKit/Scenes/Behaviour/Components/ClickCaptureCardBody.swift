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

/// Click capture demo, matching `ClickCaptureCard` in the SwiftUI sample. There
/// is no SDK call here on purpose: once the SDK is enabled, every tap is logged
/// as a click event before the button handles it.
///
/// The counter is only there to show the tap registered with the app, so a tap
/// the SDK failed to log can be told apart from one that never happened.
@MainActor
final class ClickCaptureCardBody: UIStackView {

    private var taps = 0

    private let countLabel = makeResultLabel(identifier: SampleID.Showcase.tapCount)

    /// The body in its card.
    static func makeCard() -> CardView {
        CardView(title: "Taps", arrangedSubviews: [ClickCaptureCardBody()])
    }

    init() {
        super.init(frame: .zero)

        axis = .vertical
        spacing = 10

        addArrangedSubview(makeBodyLabel("""
            Every tap is logged as a click event. Nothing to call — tap the \
            button and look for the click event in the next post.
            """))
        addArrangedSubview(
            makePrimaryButton(
                title: "Tap me",
                identifier: SampleID.Showcase.tap,
                action: UIAction { [weak self] _ in
                    self?.recordTap()
                }
            )
        )
        addArrangedSubview(countLabel)
        showCount()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func recordTap() {
        taps += 1
        showCount()
    }

    private func showCount() {
        countLabel.text = "taps: \(taps)"
        countLabel.isHidden = false
    }
}
