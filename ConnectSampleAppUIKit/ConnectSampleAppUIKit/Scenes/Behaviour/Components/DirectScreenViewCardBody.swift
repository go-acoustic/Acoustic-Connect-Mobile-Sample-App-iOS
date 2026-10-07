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

/// Sends type-2 screen views with an exact, arbitrary name through
/// `logScreenViewContext`, bypassing navigation. Matches `DirectScreenViewCard`
/// in the SwiftUI sample.
///
/// Navigation cannot carry an empty or `nil` name, so the two cases most likely
/// to still break the fallback are only reachable here.
@MainActor
final class DirectScreenViewCardBody: UIStackView {

    private let store = BehaviourStore.shared
    private var cancellables = Set<AnyCancellable>()

    private let logStack = UIStackView()
    private lazy var logBox = makeInsetBox(containing: logStack)

    /// The body in its card.
    static func makeCard() -> CardView {
        CardView(title: "Screen view — exact name", arrangedSubviews: [DirectScreenViewCardBody()])
    }

    init() {
        super.init(frame: .zero)

        axis = .vertical
        spacing = 12

        addArrangedSubview(makeBodyLabel("""
            Emits a type-2 screenview whose logical page name is the exact string \
            below. The server-side rule uses that name as the inferred pageView's \
            url, so each name is a separate test of the fallback. The empty and \
            null names are only reachable here — navigation drops them.
            """))
        addArrangedSubview(
            makePrimaryButton(
                title: "Send all \(ScreenViewCases.direct.count) names",
                identifier: SampleID.ScreenViews.sendAll,
                action: UIAction { [weak self] _ in self?.store.logAllScreenViewsDirect() }
            )
        )
        for screenViewCase in ScreenViewCases.direct {
            let probes = makeBodyLabel(screenViewCase.probes, style: .caption2)
            let block = UIStackView(arrangedSubviews: [
                makeSecondaryButton(
                    title: screenViewCase.label,
                    identifier: SampleID.ScreenViews.directButton(screenViewCase.id),
                    action: UIAction { [weak self] _ in self?.store.logScreenViewDirect(screenViewCase) }
                ),
                probes
            ])
            block.axis = .vertical
            block.spacing = 6
            addArrangedSubview(block)
        }

        logStack.axis = .vertical
        logStack.spacing = 4
        addArrangedSubview(logBox)

        observeStore()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func observeStore() {
        store.$screenViewLog
            .sink { [weak self] entries in self?.show(entries) }
            .store(in: &cancellables)
    }

    /// Lists the sends, newest first; the newest carries the result identifier.
    private func show(_ entries: [BehaviourStore.ScreenViewLogEntry]) {
        logStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, entry) in entries.enumerated() {
            let line = makeResultLabel(identifier: SampleID.ScreenViews.result)
            if index > 0 {
                line.accessibilityIdentifier = nil
            }
            line.text = entry.line
            line.isHidden = false
            logStack.addArrangedSubview(line)
        }
        logBox.isHidden = entries.isEmpty
    }
}
