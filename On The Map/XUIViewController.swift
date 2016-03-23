//
//  XUIViewController.swift
//  On The Map
//
//  Created by Shawn Burlew on 2/18/16.
//  Copyright © 2016 Shawn Burlew. All rights reserved.
//

import UIKit
import SafariServices

// UI Updates
extension UIViewController {
  
  func alert(withTitle title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alert.addAction(ok)
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  func displayURLInSafari(urlString: String) {
    // Check that url is properly formatted and uses http or https
    guard let url = NSURL(string: urlString) else {
      return self.alert(withTitle: "URL Error", message: "The link you selected is not a valid URL.")
    }
    
    if url.scheme == "http" || url.scheme == "https" {
      let safari = SFSafariViewController(URL: url)
      self.presentViewController(safari, animated: true, completion: nil)
    } else {
      UIApplication.sharedApplication().openURL(url)
    }
  }
  
  func logout() {
    // Log out with Udacity client.
    UdacityClient.sharedInstance().logoutUdacity { error in
      
      // Check for errors
      guard error == nil else {
        return self.alert(withTitle: "Logout Error", message: error!.userInfo[NSLocalizedDescriptionKey] as! String)
      }
      
      // Dismiss tab bar controller and return to login screen
      self.tabBarController!.dismissViewControllerAnimated(true, completion: nil)
    }
  }
  
  func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
      updates()
    }
  }
}