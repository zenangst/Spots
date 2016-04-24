//
//  AppDelegate.swift
//  Dashboard
//
//  Created by Christoffer Winterkvist on 23/04/16.
//  Copyright © 2016 Hyper. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    window = UIWindow(frame: UIScreen.mainScreen().bounds)

    SpotsConfigurator().configure()

    let controller = ViewController(title: "Hello")
    window?.rootViewController = controller
    window?.makeKeyAndVisible()

    return true
  }
}

