//
//  TabBarController.swift
//  On The Map
//
//  Created by Shawn Burlew on 2/24/16.
//  Copyright © 2016 Shawn Burlew. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    self.setStyling()
    
    // Only animate when app transitions from login screen
    if NSUserDefaults.standardUserDefaults().boolForKey("AlreadyAnimatedTabBar") == false {
      NSUserDefaults.standardUserDefaults().setBool(true, forKey: "AlreadyAnimatedTabBar")
      
      self.view.transform = CGAffineTransformMakeScale(0.0, 0.0)
      
      UIView.animateWithDuration(0.5) {
        self.view.transform = CGAffineTransformIdentity
      }
    }
  }
  
  func setStyling() {
    self.tabBar.tintColor = UIColor(red: 0.0, green: 0.2, blue: 0.4, alpha: 1.0)
  }
}