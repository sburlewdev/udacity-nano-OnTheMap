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
import SafariServices

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
  
  let animateLoginKey = "AlreadyAnimatedLogin"
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  override func viewDidLoad() {
    self.facebookLoginButton.delegate = self
    
    NSUserDefaults.standardUserDefaults().removeObjectForKey(self.animateLoginKey)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    // Give buttons and text fields rounded corners
    self.loginButton.layer.cornerRadius = self.loginButton.frame.height / 2.0
    self.emailTextField.layer.cornerRadius = self.emailTextField.frame.height / 2.0
    self.passwordTextField.layer.cornerRadius = self.passwordTextField.frame.height / 2.0
    
    // Toggle loginButton whenever either text field's contents change
    self.emailTextField.addTarget(self, action: #selector(LoginViewController.toggleLoginButton), forControlEvents: UIControlEvents.EditingChanged)
    self.passwordTextField.addTarget(self, action: #selector(LoginViewController.toggleLoginButton), forControlEvents: UIControlEvents.EditingChanged)
    
    self.activityIndicator.stopAnimating()
    self.toggleLoginButton()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if NSUserDefaults.standardUserDefaults().boolForKey(self.animateLoginKey) == true {
      return
    }
    
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
    
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: self.animateLoginKey)
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    // Dispose of email and password text
    self.emailTextField.text = nil
    self.passwordTextField.text = nil
  }

  @IBAction func login(sender: AnyObject) {
    // Disable UI controls while system attempts to login
    self.performUIUpdatesOnMain {
      self.emailTextField.enabled = false
      self.passwordTextField.enabled = false
      self.loginButton.enabled  = false
      self.signUpButton.enabled = false
      self.activityIndicator.startAnimating()
    }
    
    // Handle UI updates and tab view presentation
    let loginCompletionHandler: (error: NSError?) -> Void = { error in
      
      // Check for errors
      guard error == nil else {
        return self.performUIUpdatesOnMain {
          self.emailTextField.enabled = true
          self.passwordTextField.enabled = true
          self.signUpButton.enabled = true
          self.toggleLoginButton()
          self.activityIndicator.stopAnimating()
          
          self.alert(withTitle: "Login Error", message: error!.userInfo[NSLocalizedDescriptionKey] as! String)
        }
      }
      
      // Present tab view
      NSUserDefaults.standardUserDefaults().removeObjectForKey("AlreadyAnimatedTabBar")
      let tabBarVC = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
      
      self.performUIUpdatesOnMain {
        self.presentViewController(tabBarVC, animated: true, completion: nil)
      }
    } // loginCompletionHandler
    
    switch sender as! UIButton {
    case self.loginButton:
      // Login with Udacity credentials
      self.uClient.loginUdacity(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completionHandler: loginCompletionHandler)
      break
    case self.facebookLoginButton:
      // Login with Facebook access token
      self.uClient.loginFacebook(withAccessToken: FBSDKAccessToken.currentAccessToken().tokenString, completionHandler: loginCompletionHandler)
      break
    default:
      self.performUIUpdatesOnMain {
        self.alert(withTitle: "Login Error", message: "Login invoked improperly.")
      }
      break
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

// Handle Facebook login & logout
extension LoginViewController: FBSDKLoginButtonDelegate {
  
  func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
    // Do not attempt to login if user cancelled login
    if result.isCancelled == true {
      return
    }
    self.login(loginButton)
  }
  
  func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
  }
  
  func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
    return true
  }
}