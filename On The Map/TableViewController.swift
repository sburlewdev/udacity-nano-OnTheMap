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
  @IBOutlet weak var refreshButton: UIBarButtonItem!
  
  // Parse client
  let pClient = ParseClient.sharedInstance()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.edgesForExtendedLayout = .None
    
    self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
    self.refreshControl!.backgroundColor = .whiteColor()
    let attributes = [NSForegroundColorAttributeName: UIColor.blueColor()]
    self.refreshControl!.attributedTitle = NSAttributedString(string: "Last updated on \(NSDate())", attributes: attributes)
    self.refreshControl!.tintColor = .blackColor()
  }
  
  @IBAction func logout(sender: AnyObject) {
    self.logout()
  }
  
  @IBAction func refresh(sender: AnyObject) {
    self.getStudentLocations()
  }

  func getStudentLocations() {
    
    self.pClient.getStudentLocations { error in
      
      guard error == nil else {
        return self.alert(withTitle: "Download Error", message: "\(error!.userInfo[NSLocalizedDescriptionKey])")
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
    
    print("Student locations: \(self.pClient.studentLocations.count)")
    print("Index: \(indexPath.row)")
    let location = self.pClient.studentLocations[indexPath.row]
    
    cell.textLabel!.text = location.firstName + " " + location.lastName
    cell.detailTextLabel!.text = location.mediaURL?.description
    cell.imageView!.backgroundColor = .redColor()
    cell.imageView!.tintColor = .blueColor()
    
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