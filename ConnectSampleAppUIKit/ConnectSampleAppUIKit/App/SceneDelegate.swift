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

/// Builds the tab bar. Each tab is wrapped in its own `UINavigationController`
/// so pushes produce real view controllers — the screen-view behaviour this
/// sample exists to exercise.
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            navigationController(
                root: IdentityViewController(),
                title: "Identity",
                systemImage: "person.crop.circle",
                identifier: SampleID.Tab.identity
            ),
            navigationController(
                root: BehaviourViewController(),
                title: "Behaviour",
                systemImage: "chart.bar",
                identifier: SampleID.Tab.behaviour
            )
        ]
        tabBarController.tabBar.tintColor = UIColor(named: "periwinkle")

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        self.window = window
    }

    private func navigationController(
        root: UIViewController,
        title: String,
        systemImage: String,
        identifier: String
    ) -> UINavigationController {
        root.title = title
        let navigationController = UINavigationController(rootViewController: root)
        let item = UITabBarItem(
            title: title,
            image: UIImage(systemName: systemImage),
            selectedImage: nil
        )
        item.accessibilityIdentifier = identifier
        navigationController.tabBarItem = item
        return navigationController
    }
}
