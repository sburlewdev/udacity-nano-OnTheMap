//
//  AppDelegate.swift
//  On The Map
//
//  Created by Shawn Burlew on 2/18/16.
//  Copyright © 2016 Shawn Burlew. All rights reserved.
//

import UIKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  func applicationDidBecomeActive(application: UIApplication) {
    FBSDKAppEvents.activateApp()
  }
  
  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
    return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
  }
}