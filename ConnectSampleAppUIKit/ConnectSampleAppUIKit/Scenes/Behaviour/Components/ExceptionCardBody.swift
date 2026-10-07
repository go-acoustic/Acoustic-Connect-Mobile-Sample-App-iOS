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

/// `logNSExceptionEvent` demo, matching `ExceptionCard` in the SwiftUI sample.
///
/// Uncaught Objective-C exceptions are reported by the SDK on its own. This
/// card covers the other case: an error the app caught and recovered from,
/// which is invisible to the SDK unless the app reports it.
@MainActor
final class ExceptionCardBody: UIStackView {

    private let store = BehaviourStore.shared
    private var cancellables = Set<AnyCancellable>()

    private let resultLabel = makeResultLabel(identifier: SampleID.Showcase.exceptionResult)

    /// The body in its card.
    static func makeCard() -> CardView {
        CardView(title: "Exceptions", arrangedSubviews: [ExceptionCardBody()])
    }

    init() {
        super.init(frame: .zero)

        axis = .vertical
        spacing = 10

        addArrangedSubview(makeBodyLabel("""
            Uncaught exceptions are reported automatically. For errors your app \
            catches, logNSExceptionEvent(_:dataDictionary:isUnhandled:) reports \
            them explicitly. This button throws, catches and reports one.
            """))
        addArrangedSubview(
            makePrimaryButton(
                title: "Log a handled exception",
                identifier: SampleID.Showcase.exception,
                action: UIAction { [weak self] _ in
                    self?.store.logHandledException()
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
        store.$exceptionResult
            .sink { [weak self] result in
                self?.resultLabel.text = result
                self?.resultLabel.isHidden = result == nil
            }
            .store(in: &cancellables)
    }
}
