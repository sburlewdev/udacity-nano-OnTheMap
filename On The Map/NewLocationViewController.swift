//
//  NewLocationViewController.swift
//  On The Map
//
//  Created by Shawn Burlew on 2/26/16.
//  Copyright © 2016 Shawn Burlew. All rights reserved.
//

import UIKit
import MapKit

class NewLocationViewController : UIViewController {
  
  // UI Outlets
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var findSubmitButton: UIButton!
  @IBOutlet weak var locationLinkTextField: UITextField!
  @IBOutlet weak var mapView: MKMapView!
  
  private let pClient = ParseClient.sharedInstance()
  
  private var location = [String : AnyObject]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.activityIndicator.stopAnimating()
    
    self.mapView.userInteractionEnabled = false
    self.mapView.alpha = 0.2
    
    self.locationLinkTextField.layer.cornerRadius = self.locationLinkTextField.frame.height / 2.0
    self.locationLinkTextField.addTarget(self, action: "toggleFindSubmitButton", forControlEvents: .EditingChanged)
    
    self.cancelButton.layer.cornerRadius = self.cancelButton.frame.height / 2.0
    self.findSubmitButton.layer.cornerRadius = self.findSubmitButton.frame.height / 2.0
    
    self.toggleFindSubmitButton()
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  @IBAction func cancel(sender: AnyObject) {
    self.resignFirstResponder()
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func toggleFindSubmitButton() {
    self.findSubmitButton.enabled = !(self.locationLinkTextField.text?.isEmpty == true)
  }
  
  @IBAction func findOnMap(sender: AnyObject) {
    self.locationLinkTextField.resignFirstResponder()
    
    guard self.findSubmitButton.titleLabel?.text == "Find Location" else {
      return
    }
      self.cancelButton.enabled = false
      self.activityIndicator.startAnimating()
      
      // Populate location
      self.location[JSONResponseKeys.PMapString] = self.locationLinkTextField.text!
      
      // Forward-geocode string to get lat/lon coordinates
      CLGeocoder().geocodeAddressString(self.locationLinkTextField.text!) { placemarks, error in
        
      // Check for errors
      guard error == nil else {
        return self.alert(withTitle: "New Location Error", message: error!.userInfo[NSLocalizedDescriptionKey] as! String)
      }
      
      // Validate data
      guard let coordinates = placemarks?.first?.location?.coordinate else {
        return self.alert(withTitle: "New Location Error", message: ErrorMessageKeys.FindFailure + "coordinates")
      }
      
      guard coordinates.latitude.isZero == false else {
        return self.alert(withTitle: "New Location Error", message: "Latitude cannot be zero")
      }
      
      guard coordinates.longitude.isZero == false else {
        return self.alert(withTitle: "New Location Error", message: "Longitude cannot be zero")
      }
        
      let pin = MKPointAnnotation()
      pin.coordinate = coordinates
      pin.title = (self.location[JSONResponseKeys.PMapString] as! String)
      
      // Populate location
      self.location[JSONResponseKeys.PUniqueKey] = NSDate.stringFromDate(NSDate())
      self.location[JSONResponseKeys.PFirstName] = self.pClient.firstName
      self.location[JSONResponseKeys.PLastName] = self.pClient.lastName
      self.location[JSONResponseKeys.PLatitude] = pin.coordinate.latitude
      self.location[JSONResponseKeys.PLongitude] = pin.coordinate.longitude
      
      // Provide a 50 km radius for the mapView's region to display
      let radius: CLLocationDistance = 50000
      let coordinateRegion = MKCoordinateRegionMakeWithDistance(pin.coordinate, radius * 2, radius * 2)
      
      UIView.animateWithDuration(0.3) {
        self.mapView.alpha = 1.0
      }
      
      self.performUIUpdatesOnMain {
        self.mapView.addAnnotation(pin)
        self.mapView.setRegion(coordinateRegion, animated: true)
        self.mapView.selectAnnotation(pin, animated: true)
        self.activityIndicator.stopAnimating()
        
        self.toggleButtons(true)
        self.findSubmitButton.setTitle("Submit", forState: .Normal)
        
        self.locationLinkTextField.text = nil
        self.locationLinkTextField.placeholder = "Enter a website to share"
      }
    }
  }
  
  @IBAction func submit(sender: AnyObject) {
    
    guard self.findSubmitButton.titleLabel?.text == "Submit" else {
      return
    }
    
    // Prevent user from accidentally submitting a new location twice
    self.toggleButtons(false)
    
    // Populate location
    self.location[JSONResponseKeys.PMediaURL] = self.locationLinkTextField.text!
    self.location[JSONResponseKeys.PUniqueKey] = NSDate.stringFromDate(NSDate())
    
    self.pClient.createStudentLocation(self.location) { error in
      
      guard error == nil else {
        self.toggleButtons(true)
        return self.alert(withTitle: "New Location Error", message: error!.userInfo[NSLocalizedDescriptionKey] as! String)
      }
      self.cancel(self)
    }
  }
  
  func toggleButtons(enabled: Bool) {
    self.findSubmitButton.enabled = enabled
    self.cancelButton.enabled = enabled
  }
}