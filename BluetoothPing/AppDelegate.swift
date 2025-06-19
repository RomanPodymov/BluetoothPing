//
//  AppDelegate.swift
//  BluetoothPing
//
//  Created by Roman Podymov on 07/05/2024.
//  Copyright © 2024 BluetoothPing. All rights reserved.
//

import Resolver
import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        Resolver.register { CentralManager.shared }
            .implements(CentralManagerInterface.self)

        window = UIWindow(frame: UIScreen.main.bounds)
        let rootController = UINavigationController(rootViewController: DevicesScreen())
        window?.rootViewController = rootController
        window?.makeKeyAndVisible()

        return true
    }
}
