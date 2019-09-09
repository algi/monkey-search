//
//  SceneDelegate.swift
//  MonkeySearch
//
//  Created by Marian Bouček on 28/08/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to find correct application delegate.")
        }

        let provider = DataProvider(container: delegate.persistentContainer)
        let contentView = ContentView(provider: provider)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: contentView)

        self.window = window
        window.makeKeyAndVisible()
    }
}
