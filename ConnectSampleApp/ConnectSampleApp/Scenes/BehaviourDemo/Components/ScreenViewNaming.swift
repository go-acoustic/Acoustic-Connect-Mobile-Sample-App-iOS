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

extension View {

    /// Names the screen view the SDK logs when this view appears.
    ///
    /// Without a name the SDK falls back to the view controller's class, which
    /// is `UIHostingController` for every SwiftUI screen. `onAppear` runs before
    /// the hosting controller's `viewDidAppear`, where the SDK takes the name,
    /// so the name is in place in time — and it runs again when the view
    /// reappears after a pop, which re-names the screen the user came back to.
    ///
    /// - Note: Pushed and presented SwiftUI screens take the name from a
    ///   Connect iOS build newer than 2.1.41. Older builds applied it only to a
    ///   tab's root, and logged every other SwiftUI screen under its
    ///   hosting-controller class.
    ///
    /// - Parameter name: The name to log.
    /// - Returns: The view, named.
    ///
    /// ## Example
    /// ```swift
    /// ShowcaseView()
    ///     .logsScreenView(named: "Showcase")
    /// ```
    func logsScreenView(named name: String) -> some View {
        onAppear { SampleScreenNaming.nameCurrentScreen(name) }
    }
}

extension BehaviourRoute {

    /// Dresses a screen as this route: navigation-bar title, and the screen name
    /// the SDK logs on arrival.
    ///
    /// Every push in the Behaviour stack goes through here, so a route's title
    /// and its logged name cannot drift apart.
    ///
    /// - Parameter content: The screen's content.
    /// - Returns: The content, titled and named.
    ///
    /// ## Example
    /// ```swift
    /// NavigationLink(destination: BehaviourRoute.showcase.screen(ShowcaseView())) {
    ///     Text("Open Showcase")
    /// }
    /// ```
    func screen<Content: View>(_ content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .logsScreenView(named: screenName)
    }
}
