//
//  AppDelegate.swift
//  JSQMessDemo
//
//  Created by Do Tuan on 2017/02/10.
//  Copyright © 2017 Do Tuan. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Crashlytics.self])
        return true
    }

}

