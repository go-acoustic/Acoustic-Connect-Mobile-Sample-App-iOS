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

/// WebView POST screen — checks that the SDK's WebView capture does not turn a
/// form POST into a GET. Pushed from the Verification screen; matches
/// `WebViewPostView` in the SwiftUI sample.
///
/// The check itself lives in ``WebViewPostModel``, shared with the SwiftUI
/// sample; this screen only lays it out.
@MainActor
final class WebViewPostViewController: CardListViewController {

    override var screenName: String? { BehaviourRoute.webViewPost.screenName }

    private let model = WebViewPostModel()
    private var cancellables = Set<AnyCancellable>()

    private let statusLabel = makeBodyLabel("", style: .caption2)
    private let navigationsLabel = makeBodyLabel("", style: .caption2)

    override func viewDidLoad() {
        super.viewDidLoad()
        setCards([scenarioCard(), webViewCard()])
        observeModel()
    }

    // MARK: - Cards

    private func scenarioCard() -> CardView {
        for label in [statusLabel, navigationsLabel] {
            label.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
            label.textColor = UIColor(named: "violet")
        }
        let status = UIStackView(arrangedSubviews: [statusLabel, navigationsLabel])
        status.axis = .vertical
        status.spacing = 4

        return makeScenarioCard(
            scenario: Scenarios.webViewPostNotReplayedAsGet,
            body: [
                makeInsetBox(containing: status),
                makePrimaryButton(
                    title: "Submit payment (POST)",
                    identifier: SampleID.WebView.submit,
                    action: UIAction { [weak self] _ in self?.model.submit() }
                ),
                makeSecondaryButton(
                    title: "Capture layout now (triggers the reload)",
                    identifier: SampleID.WebView.capture,
                    action: UIAction { [weak self] _ in self?.model.captureLayout() }
                ),
                makeBodyLabel("""
                    Scroll the WebView fully into view before capturing — the capture \
                    skips off-screen subtrees, so a WebView below the fold yields a \
                    layout with no WebView nodes.
                    """, style: .caption1),
                makeSecondaryButton(
                    title: "Reload form",
                    identifier: SampleID.WebView.reset,
                    action: UIAction { [weak self] _ in self?.model.reset() }
                )
            ]
        )
    }

    private func webViewCard() -> CardView {
        let webView = model.webView
        webView.layer.cornerRadius = 8
        webView.clipsToBounds = true
        webView.heightAnchor.constraint(equalToConstant: 420).isActive = true
        return CardView(title: "WebView", arrangedSubviews: [webView])
    }

    // MARK: - Model

    private func observeModel() {
        model.$status
            .sink { [weak self] status in
                self?.statusLabel.text = WebViewPostModel.statusText(status)
            }
            .store(in: &cancellables)
        model.$navigations
            .sink { [weak self] count in
                self?.navigationsLabel.text = "navigations: \(count)"
            }
            .store(in: &cancellables)
    }
}
