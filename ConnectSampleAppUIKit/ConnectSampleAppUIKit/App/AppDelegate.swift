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
import UIKit

/// Analytics-only sample. No push entitlements, no notification extensions —
/// `ConnectSDK.enable(appKey:postURL:)` leaves push off by default, so nothing
/// here needs a certificate or a provisioning profile.
@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    override init() {
        super.init()
        #if DEBUG
        // SDK debug logging, Debug builds only. setenv with overwrite=0 so any
        // value already in the environment wins.
        //
        // The push sample sets these unconditionally because its simulator
        // builds are distributed through Artifactory, where no debugger sets
        // env vars. This sample is only ever built locally, so there is no
        // reason to leave logging on in Release.
        setenv("CONNECT_DEBUG", "1", 0)
        setenv("TLF_DEBUG", "1", 0)
        setenv("EODebug", "1", 0)
        #endif
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Credentials live in the push sample's ConnectSDKManager, which this
        // target compiles rather than copies — one source of truth for both apps.
        ConnectSDKManager.shared.startAnalyticsOnly()
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
