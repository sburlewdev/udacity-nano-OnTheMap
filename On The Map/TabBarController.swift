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
    
    self.view.transform = CGAffineTransformMakeScale(0.0, 0.0)
    
    UIView.animateWithDuration(0.5) {
      self.view.transform = CGAffineTransformIdentity
    }
  }
}