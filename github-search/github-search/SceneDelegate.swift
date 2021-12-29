//
//  SceneDelegate.swift
//  github-search
//
//  Created by Liubov Kovalchuk on 26.12.2021.
//

import UIKit

struct Constants {
    static let userActivityRestorationKey = "userActivityRestorationKey"
    static let restorationKey = "restorationKey"
}


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        let userActivity = session.stateRestorationActivity ?? NSUserActivity(activityType: Constants.userActivityRestorationKey)
        scene.userActivity = userActivity
        if let restorationState = (userActivity.userInfo?[Constants.restorationKey] as? Data)
            .flatMap({try? JSONDecoder().decode(RestorationState.self, from: $0)}) {
            (window?.rootViewController as! SearchViewController).restorationState = restorationState
        }
    }
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        scene.userActivity
    }
}

