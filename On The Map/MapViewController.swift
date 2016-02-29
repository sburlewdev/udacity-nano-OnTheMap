//
//  MapViewController.swift
//  On The Map
//
//  Created by Shawn Burlew on 2/18/16.
//  Copyright © 2016 Shawn Burlew. All rights reserved.
//

import UIKit
import MapKit
import Contacts

class MapViewController: UIViewController {
  
  // UI Outlets
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var logoutButton: UIBarButtonItem!
  @IBOutlet weak var markerButton: UIBarButtonItem!
  @IBOutlet weak var refreshButton: UIBarButtonItem!
  
  // Parse client
  let pClient = ParseClient.sharedInstance()
  
  // Student location query parameters
  let parameters: JSON = [
    "limit" : "100"
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.mapView.delegate = self
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if self.pClient.studentLocations.isEmpty {
      self.refresh(self)
    } else {
      self.updatePinAnnotations()
    }
  }
  
  @IBAction func logout(sender: AnyObject) {
    self.logout()
  }
  
  @IBAction func refresh(sender: AnyObject) {
    pClient.getStudentLocations(withParameters: self.parameters) { error in
      
      // Check for errors
      guard error == nil else {
        return self.alert(withTitle: "Download Error", message: error!.userInfo[NSLocalizedDescriptionKey] as! String)
      }
      // Update pin annotations on mapView
      self.updatePinAnnotations()
    }
  }
  
  func updatePinAnnotations() {
    
    var pins = [MKPointAnnotation]()
    for location in self.pClient.studentLocations {
      let pin = MKPointAnnotation()
      pin.title = location.firstName + " " + location.lastName
      pin.subtitle = location.mediaURL?.description
      pin.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
      pins.append(pin)
    }
    // Update UI
    self.performUIUpdatesOnMain {
      // Remove old annotations
      self.mapView.removeAnnotations(self.mapView.annotations)
      // Add new annotations
      self.mapView.addAnnotations(pins)
    }
  }
}

// MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
  
  func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    let annotation = view.annotation!
    let urlString = annotation.subtitle!!
    self.displayURLInSafari(urlString)
  }
  
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    let identifier = "pin"
    var view: MKPinAnnotationView
    if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
      view = dequeuedView
    } else {
      view = MKPinAnnotationView(annotation: nil, reuseIdentifier: identifier)
      view.canShowCallout = true
      view.calloutOffset = CGPoint(x: -5, y: 5)
      view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
    }
    return view
  }
}