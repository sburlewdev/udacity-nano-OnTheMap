//
//  StudentInformation.swift
//  On The Map
//
//  Created by Shawn Burlew on 2/22/16.
//  Copyright © 2016 Shawn Burlew. All rights reserved.
//

import Foundation

struct StudentInformation {
  
  let createdAt: NSDate
  let firstName: String
  let lastName: String
  let latitude: Double
  let longitude: Double
  let mapString: String
  let mediaURL: NSURL?
  let objectID: String
  let uniqueKey: String
  let updatedAt: NSDate
  
  init(dictionary: [String : AnyObject]) {
    self.firstName = dictionary[JSONResponseKeys.PFirstName] as! String
    self.lastName = dictionary[JSONResponseKeys.PLastName] as! String
    self.latitude = dictionary[JSONResponseKeys.PLatitude] as! Double
    self.longitude = dictionary[JSONResponseKeys.PLongitude] as! Double
    self.mapString = dictionary[JSONResponseKeys.PMapString] as! String
    self.objectID = dictionary[JSONResponseKeys.PObjectID] as! String
    self.uniqueKey = dictionary[JSONResponseKeys.PUniqueKey] as! String
    
    let mediaURLString = dictionary[JSONResponseKeys.PMediaURL] as! String
    self.mediaURL = NSURL(string: mediaURLString)
    
    let createdAt = dictionary[JSONResponseKeys.PCreatedAt] as! String
    self.createdAt = NSDate.dateFromString(createdAt)
    let updatedAt = dictionary[JSONResponseKeys.PUpdatedAt] as! String
    self.updatedAt = NSDate.dateFromString(updatedAt)
  }
}

// Get string for date with non-standard date format
extension NSDate {
  
  private class func dateFormatter() -> NSDateFormatter {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    return dateFormatter
  }
  
  class func stringFromDate(date: NSDate) -> String {
    return NSDate.dateFormatter().stringFromDate(date)
  }
  
  class func dateFromString(string: String) -> NSDate {
    return NSDate.dateFormatter().dateFromString(string) ?? NSDate()
  }
}