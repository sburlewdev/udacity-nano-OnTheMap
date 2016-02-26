//
//  TableViewController.swift
//  On The Map
//
//  Created by Shawn Burlew on 2/23/16.
//  Copyright © 2016 Shawn Burlew. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
  
  // UI Outlets
  @IBOutlet weak var markerButton: UIBarButtonItem!
  @IBOutlet weak var refreshButton: UIBarButtonItem!
  
  // Parse client
  let pClient = ParseClient.sharedInstance()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.edgesForExtendedLayout = .None
    
    self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
    self.refreshControl!.backgroundColor = .whiteColor()
    let attributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
    self.refreshControl!.attributedTitle = NSAttributedString(string: "Last updated on \(NSDate())", attributes: attributes)
    self.refreshControl!.tintColor = .blackColor()
  }
  
  @IBAction func logout(sender: AnyObject) {
    self.logout()
  }
  
  @IBAction func createNewLocation(sender: AnyObject) {
    
    var location: [String : AnyObject] = [
      JSONResponseKeys.UniqueKey : "blergh!!",
      JSONResponseKeys.FirstName : "test",
      JSONResponseKeys.LastName : "bros",
      JSONResponseKeys.MapString : "Somewhere Over the Rainbow",
      JSONResponseKeys.MediaURL : "https://www.realm.io",
      JSONResponseKeys.Latitude : 0.0,
      JSONResponseKeys.Longitude : 5.0
    ]
    
    self.pClient.createStudentLocation(location) { error in
      
      guard error == nil else {
        return self.alert(withTitle: "New Location Error", message: error!.userInfo[NSLocalizedDescriptionKey] as! String)
      }
      
      self.refresh(self)
    }
  }
  
  @IBAction func refresh(sender: AnyObject) {
    let attributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
    self.refreshControl!.attributedTitle = NSAttributedString(string: "Last updated on \(NSDate())", attributes: attributes)
    
    self.pClient.getStudentLocations { error in
      
      self.tableView.reloadData()
      guard error == nil else {
        return self.alert(withTitle: "Download Error", message: error!.userInfo[NSLocalizedDescriptionKey] as! String)
      }
      self.performUIUpdatesOnMain {
        self.tableView.reloadData()
        self.refreshControl!.endRefreshing()
      }
    }
  }
}

// UITableViewDataSource & UITableViewDelegate
extension TableViewController {
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCellWithIdentifier("MapTableCell")!
    
    if indexPath.row < self.pClient.studentLocations.count {
      let location = self.pClient.studentLocations[indexPath.row]
      let cellColors: [UIColor] = [
        .blueColor(),
        .purpleColor(),
        .redColor(),
        .orangeColor(),
        .yellowColor(),
        .greenColor()
      ]
      
      cell.textLabel!.text = location.firstName + " " + location.lastName
      cell.detailTextLabel!.text = location.mediaURL?.description
      cell.imageView!.backgroundColor = cellColors[indexPath.row % cellColors.count]
      performUIUpdatesOnMain {
        cell.imageView!.layer.cornerRadius = cell.imageView!.frame.height / 2.0
      }
    }
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    let cell = self.tableView.cellForRowAtIndexPath(indexPath)
    let urlString = cell?.detailTextLabel!.text!
    self.displayURLInSafari(urlString!)
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.pClient.studentLocations.count
  }
}