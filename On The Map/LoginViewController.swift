//
//  LoginViewController.swift
//  On The Map
//
//  Created by Shawn Burlew on 2/18/16.
//  Copyright © 2016 Shawn Burlew. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
  
  // UI Outlets
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var loginLabel: UILabel!
  @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
  @IBOutlet weak var signUpButton: UIButton!
  @IBOutlet weak var logoImageView: UIImageView!
  
  // Udacity client
  let uClient = UdacityClient.sharedInstance()
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    // Give buttons and text fields rounded corners
    self.facebookLoginButton.layer.cornerRadius =  self.facebookLoginButton.frame.height / 2.0
    self.loginButton.layer.cornerRadius = self.loginButton.frame.height / 2.0
    self.emailTextField.layer.cornerRadius = self.emailTextField.frame.height / 2.0
    self.passwordTextField.layer.cornerRadius = self.passwordTextField.frame.height / 2.0
    
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
    self.facebookLoginButton.center.x -= self.view.frame.width
    
    let height = self.logoImageView.frame.height / 2.0
    self.logoImageView.alpha = 0.0
    self.logoImageView.center.y += height
    self.logoImageView.transform = CGAffineTransformMakeScale(0.2, 0.2)
    
    self.loginLabel.alpha = 0.0
    self.signUpButton.alpha = 0.0
    
    UIView.animateWithDuration(1.0) {
      self.logoImageView.alpha = 1.0
      self.logoImageView.center.y -= height
      self.logoImageView.transform = CGAffineTransformIdentity
    }
    UIView.animateWithDuration(0.5,
      delay: 1.0,
      options: [],
      animations: { self.emailTextField.center.x += self.view.frame.width },
      completion: nil)
    UIView.animateWithDuration(0.5,
      delay: 1.2,
      options: [],
      animations: { self.passwordTextField.center.x += self.view.frame.width },
      completion: nil)
    UIView.animateWithDuration(0.5,
      delay: 1.4,
      options: [],
      animations: { self.loginButton.center.x += self.view.frame.width },
      completion: nil)
    UIView.animateWithDuration(0.5,
      delay: 1.6,
      options: [],
      animations: { self.facebookLoginButton.center.x += self.view.frame.width },
      completion: nil)
    UIView.animateWithDuration(0.3,
      delay: 1.8,
      options: [],
      animations: {
        self.loginLabel.alpha = 1.0
        self.signUpButton.alpha = 1.0
      },
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
      
      // Check for errors
      guard error == nil else {
        self.performUIUpdatesOnMain {
          self.emailTextField.enabled = true
          self.passwordTextField.enabled = true
          self.signUpButton.enabled = true
          self.toggleLoginButton()
          self.activityIndicator.stopAnimating()
        }
        return self.alert(withTitle: "Login Error", message: error!.userInfo[NSLocalizedDescriptionKey] as! String)
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