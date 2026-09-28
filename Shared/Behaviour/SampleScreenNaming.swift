//
// Copyright (C) 2026 Acoustic, L.P. All rights reserved.
//
// Licensed under the Acoustic License (the "License"); you may not use
// this file except in compliance with the License. You may obtain a copy
// at https://www.acoustic.com/licenses/acoustic-license
//
// Sample app provided "as is", without warranty of any kind.
//

import Connect
import Foundation

/// Names the screen the SDK is about to log.
///
/// iOS captures a screen view on its own, but derives the name from the view
/// controller's class — `UIHostingController` for every SwiftUI screen, which
/// tells a reader nothing. Supplying a name replaces the inferred one, which is
/// what makes the samples' screen names comparable with React Native's.
///
/// Call this as the screen appears, before the capture fires: `onAppear` in
/// SwiftUI, `viewWillAppear` in UIKit. Both samples route through here so they
/// cannot name the same screen differently.
@MainActor
enum SampleScreenNaming {

    /// Sets the logical page name for the screen now appearing.
    ///
    /// - Parameter name: The name to log, from ``BehaviourRoute/screenName``.
    ///
    /// ## Example
    /// ```swift
    /// override func viewWillAppear(_ animated: Bool) {
    ///     super.viewWillAppear(animated)
    ///     SampleScreenNaming.nameCurrentScreen(route.screenName)
    /// }
    /// ```
    static func nameCurrentScreen(_ name: String) {
        ConnectSDK.shared.setCurrentScreen(pageName: name)
    }
}
