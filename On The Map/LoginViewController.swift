//
//  LoginViewController.swift
//  On The Map
//
//  Created by Shawn Burlew on 2/18/16.
//  Copyright © 2016 Shawn Burlew. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
  
  // UI Outlets
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var signUpButton: UIButton!
  
  // Udacity client
  let uClient = UdacityClient.sharedInstance()
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    // Round the corners of loginButton
    self.loginButton.layer.cornerRadius = self.loginButton.frame.height / 2.0
    
    // Toggle loginButton whenever either text field's contents change
    self.emailTextField.addTarget(self, action: "toggleLoginButton", forControlEvents: UIControlEvents.EditingChanged)
    self.passwordTextField.addTarget(self, action: "toggleLoginButton", forControlEvents: UIControlEvents.EditingChanged)
    
    self.activityIndicator.stopAnimating()
    self.toggleLoginButton()
  }
  
  override func viewWillAppear(animated: Bool) {
    self.emailTextField.center.x -= self.view.frame.width
    self.passwordTextField.center.x -= self.view.frame.width
    self.loginButton.center.x -= self.view.frame.width
    
    UIView.animateWithDuration(0.5) {
      self.emailTextField.center.x += self.view.frame.width
    }
    UIView.animateWithDuration(0.5,
      delay: 0.2,
      options: [],
      animations: { self.passwordTextField.center.x += self.view.frame.width },
      completion: nil)
    UIView.animateWithDuration(0.5,
      delay: 0.4,
      options: [],
      animations: { self.loginButton.center.x += self.view.frame.width },
      completion: nil)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    // Dispose of email and password text
    self.emailTextField.text = nil
    self.passwordTextField.text = nil
  }

  @IBAction func login(sender: AnyObject) {
    self.performUIUpdatesOnMain {
      self.emailTextField.enabled = false
      self.passwordTextField.enabled = false
      self.loginButton.enabled  = false
      self.signUpButton.enabled = false
      self.activityIndicator.startAnimating()
    }
    
    // Login to Udacity and display student locations
    self.uClient.loginUdacity(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { error in
      
      // Re-enable user to take actions regardless of login success or failure.
      self.performUIUpdatesOnMain {
        self.emailTextField.enabled = true
        self.passwordTextField.enabled = true
        self.signUpButton.enabled = true
        self.toggleLoginButton()
        self.activityIndicator.stopAnimating()
      }
      
      // Check for errors
      guard error == nil else {
        return self.alert(withTitle: "Login Error", message: "\(error!.userInfo[NSLocalizedDescriptionKey]!)")
      }
      
      // Present tab bar controller
      NSUserDefaults.standardUserDefaults().setBool(false, forKey: "AlreadyAnimatedTabBar")
      let tabBarVC = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
      self.presentViewController(tabBarVC, animated: true, completion: nil)
    }
  }
  
  @IBAction func signUp(sender: AnyObject) {
    self.displayURLInSafari("https://www.udacity.com/account/auth#!/signup")
  }
  
  func toggleLoginButton() {
    // Disable login button if either text field is empty
    self.loginButton.enabled = !(self.emailTextField.text?.isEmpty == true || self.passwordTextField.text?.isEmpty == true)
  }
}