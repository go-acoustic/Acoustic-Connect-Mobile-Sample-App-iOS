//
// Copyright (C) 2026 Acoustic, L.P. All rights reserved.
//
// Licensed under the Acoustic License (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy
// at https://www.acoustic.com/licenses/acoustic-license
//
// Sample app provided "as is", without warranty of any kind.
//

import SwiftUI
import UIKit

/// One tab of the sample: its tab-bar title, symbol and accessibility
/// identifier, kept together so the three cannot drift apart.
///
/// An enum so that ``allCases`` lists every tab: a tab added here is tagged on
/// the tab bar without a second list to keep in step.
enum SampleTab: CaseIterable {
    case push
    case identity
    case behaviour

    /// The tab-bar title, which is also how the tab's `UITabBarItem` is found.
    var title: String {
        switch self {
        case .push: return "Push"
        case .identity: return "Identity"
        case .behaviour: return "Behaviour"
        }
    }

    /// The SF Symbol on the tab-bar button.
    var systemImage: String {
        switch self {
        case .push: return "bell"
        case .identity: return "person.crop.circle"
        case .behaviour: return "chart.bar"
        }
    }

    /// The accessibility identifier on the tab-bar button.
    var identifier: String {
        switch self {
        case .push: return SampleID.Tab.push
        case .identity: return SampleID.Tab.identity
        case .behaviour: return SampleID.Tab.behaviour
        }
    }
}

extension View {

    /// Makes this view the content of `tab` in a `TabView`, with the tab's
    /// identifier on its tab-bar button.
    ///
    /// SwiftUI does not pass an `accessibilityIdentifier` on to the tab-bar
    /// button, whether it is set on the tab's content or on the label inside
    /// `tabItem`. So the identifier goes on the `UITabBarItem` UIKit builds for
    /// the tab, as it does in the UIKit sample.
    ///
    /// - Parameter tab: The tab this view is the content of.
    /// - Returns: The view, as that tab.
    ///
    /// ## Example
    /// ```swift
    /// TabView {
    ///     PushDemoView()
    ///         .sampleTab(.push)
    /// }
    /// ```
    func sampleTab(_ tab: SampleTab) -> some View {
        background(TabBarItemIdentifiers())
            .tabItem {
                Label(tab.title, systemImage: tab.systemImage)
            }
    }
}

/// Sets each tab-bar item's accessibility identifier, matching items to tabs by
/// title.
///
/// By title rather than by position, so the identifiers do not depend on the
/// order the tabs are declared in the `TabView`; the title on the item comes
/// from the same ``SampleTab`` as the identifier.
///
/// A view rather than a view controller, so it adds no screen view of its own.
/// It tags every item, not only its own tab's, because SwiftUI loads a tab's
/// content only once it is selected; and it tags them again each time its tab
/// is shown, in case SwiftUI has rebuilt the items in between.
private struct TabBarItemIdentifiers: UIViewRepresentable {
    func makeUIView(context: Context) -> InstallerView {
        InstallerView()
    }

    func updateUIView(_ view: InstallerView, context: Context) {
        view.install()
    }

    final class InstallerView: UIView {
        init() {
            super.init(frame: .zero)
            isUserInteractionEnabled = false
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            install()
        }

        func install() {
            var responder = next
            while let current = responder, !(current is UITabBarController) {
                responder = current.next
            }
            guard let items = (responder as? UITabBarController)?.tabBar.items else { return }
            for item in items {
                if let tab = SampleTab.allCases.first(where: { $0.title == item.title }) {
                    item.accessibilityIdentifier = tab.identifier
                }
            }
        }
    }
}
