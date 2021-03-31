//
//  AppDelegate.swift
//  FYPageViewDemo
//
//  Created by sven on 2021/3/31.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let mainWindow = UIWindow(frame: UIScreen.main.bounds)
        let navigation = UINavigationController(rootViewController: DemoViewController())
        mainWindow.rootViewController = navigation
        window = mainWindow
        window?.makeKeyAndVisible()

        return true
    }
}

