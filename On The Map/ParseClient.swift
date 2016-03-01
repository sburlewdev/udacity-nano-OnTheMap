//
//  ParseClient.swift
//  On The Map
//
//  Created by Shawn Burlew on 2/18/16.
//  Copyright © 2016 Shawn Burlew. All rights reserved.
//

import Foundation

class ParseClient {
  
  // App & API keys
  private static let appID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
  private static let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
  
  // Parse API Path
  private static let apiPath = "https://api.parse.com/1"
  
  // Session ID (get from Udacity client)
  private var sessionID: String!
  
  // User ID
  private (set) var userID: String!
  
  // User First & Last Name
  private (set) var firstName: String!
  private (set) var lastName: String!
  
  // ObjectID
  private var objectID: String!
  
  // Student location data for display
  private (set) var studentLocations = [StudentInformation]()
  
  func setUserInfo(sessionID: String, userID: String?, firstName: String?, lastName: String?) {
    self.sessionID = sessionID
    self.userID = userID
    self.firstName = firstName
    self.lastName = lastName
  }
  
  func reset(sessionID: String) -> Bool {
    // Only reset if the function's caller has the correct session ID
    if self.sessionID == sessionID {
      self.sessionID = nil
      self.userID = nil
      self.firstName = nil
      self.lastName = nil
      self.objectID = nil
      self.studentLocations = [StudentInformation]()
      return true
    }
    return false
  }
}

////////////////////////////////////////////////////////////////////////////////
// NETWORKING LEVEL 3 - INTERFACE METHODS
// 1. Call level 2 method with completion handler:
//   1. Check for errors from level 2
//   2. Handle data from level 2
//   3. Call external completion handler
////////////////////////////////////////////////////////////////////////////////
extension ParseClient {
  
  func getStudentLocations(withParameters parameters: JSON, completionHandler: (error: NSError?) -> Void) {
    
    // 1. Call level 2 method
    self.getStudentLocations(withParameters: self.substituteParameters(parameters)) { locations, error in
      
      // 1. Check for errors
      guard error == nil else {
        return completionHandler(error: error!)
      }
      
      // 2. Handle data
      self.studentLocations.removeAll()
      for location in locations! {
        self.studentLocations.append(StudentInformation(dictionary: location))
      }
      self.studentLocations.sortInPlace { NSDate.stringFromDate($0.0.createdAt) > NSDate.stringFromDate($0.1.createdAt) }
      
      // 3. Call external completion handler
      completionHandler(error: nil)
    }
  }
  
  func createStudentLocation(newLocation: JSON, completionHandler: (error: NSError?) -> Void) {
    var json = "{\n"
    json += "  \"\(JSONResponseKeys.PUniqueKey)\": \"\(newLocation[JSONResponseKeys.PUniqueKey] as! String)\",\n"
    json += "  \"\(JSONResponseKeys.PFirstName)\": \"\(newLocation[JSONResponseKeys.PFirstName] as! String)\",\n"
    json += "  \"\(JSONResponseKeys.PLastName)\": \"\(newLocation[JSONResponseKeys.PLastName] as! String)\",\n"
    json += "  \"\(JSONResponseKeys.PMapString)\": \"\(newLocation[JSONResponseKeys.PMapString] as! String)\",\n"
    json += "  \"\(JSONResponseKeys.PMediaURL)\": \"\(newLocation[JSONResponseKeys.PMediaURL] as! String)\",\n"
    json += "  \"\(JSONResponseKeys.PLatitude)\": \(newLocation[JSONResponseKeys.PLatitude] as! Float),\n"
    json += "  \"\(JSONResponseKeys.PLongitude)\": \(newLocation[JSONResponseKeys.PLongitude] as! Float)\n"
    json += "}"
    
    self.newStudentLocation(json) { newLocationInfo, error in
      
      // 1. Check for errors
      guard error == nil else {
        return completionHandler(error: error!)
      }
      
      // 2. Handle data
      self.objectID = newLocationInfo[JSONResponseKeys.PObjectID] as! String
      
      // 3. Call external completion handler
      completionHandler(error: nil)
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
// NETWORKING LEVEL 2 - API METHODS
// 1. Call level 1 method with method (and JSON body) with completion handler:
//   1. Check for errors from level 1
//   2. Construct JSON object from data
//   3. Parse through JSON object
//   4. Pass appropriate values up to level 3
////////////////////////////////////////////////////////////////////////////////
extension ParseClient {
  
  private func getStudentLocations(withParameters parameters: String, completionHandler: (locations: [JSON]!, error: NSError?) -> Void) {
    let domain = ErrorDomain.Parse + "getStudentLocations"
    
    // 1. Call level 1 method
    self.get(method: ParseMethods.StudentLocation, parameters: parameters) { data, error in
      
      // 1. Check for errors
      guard error == nil else {
        return completionHandler(locations: nil, error: error!)
      }
      
      // 2. Construct JSON object from data
      let parsedResult: AnyObject!
      do {
        parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
      } catch {
        return completionHandler(locations: nil, error: NSError.getError(withDomain: domain, message: ErrorMessageKeys.ParseFailure))
      }
      
      // 3. Parse through JSON object
      guard let locations = parsedResult[JSONResponseKeys.PResultsArray] as? [JSON] else {
        return completionHandler(locations: nil, error: NSError.getError(withDomain: domain, message: ErrorMessageKeys.FindFailure + "results array"))
      }
      
      // 4. Pass locations list up
      completionHandler(locations: locations, error: nil)
    }
  }
  
  private func newStudentLocation(jsonBody: String, completionHandler: (newLocationInfo: JSON!, error: NSError?) -> Void) {
    let domain = ErrorDomain.Parse + "newStudentLocation"
    
    // 1. Call level 1 method
    self.post(method: ParseMethods.StudentLocation, jsonBody: jsonBody) { data, error in
      
      // 1. Check for errors
      guard error == nil else {
        return completionHandler(newLocationInfo: nil, error: error!)
      }
      
      // 2. Construct JSON object from data
      let parsedResult: AnyObject!
      do {
        parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
      } catch {
        return completionHandler(newLocationInfo: nil, error: NSError.getError(withDomain: domain, message: ErrorMessageKeys.ParseFailure))
      }
      
      // 3. Parse through JSON object
      guard let objectID = (parsedResult as! JSON)[JSONResponseKeys.PObjectID] else {
        return completionHandler(newLocationInfo: nil, error: NSError.getError(withDomain: domain, message: ErrorMessageKeys.FindFailure + "object ID"))
      }
      
      let newLocationInfo : JSON = [ JSONResponseKeys.PObjectID : objectID ]
      
      // 4. Pass new location info up
      completionHandler(newLocationInfo: newLocationInfo, error: nil)
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
// NETWORKING LEVEL 1 - DATA TASKS
// 1. Create URL request with method (and JSON body)
// 2. Create data task, pass in JSONCompletionHandler
////////////////////////////////////////////////////////////////////////////////
extension ParseClient: NetworkClient {
  
  private func get(method method: String, parameters: String, jsonCompletionHandler: JSONCompletionHandler) {
    let domain = ErrorDomain.Parse + HTTPMethods.Get
    let url = NSURL(string: ParseClient.apiPath + method + parameters)!
    
    // 1. Create URL request
    let request = NSMutableURLRequest(URL: url)
    request.addValue(ParseClient.appID, forHTTPHeaderField: HTTPHeaderKeys.ParseApplicationID)
    request.addValue(ParseClient.apiKey, forHTTPHeaderField: HTTPHeaderKeys.ParseRESTAPIKey)
    
    // 2. Create data task
    self.dataTask(request, errorDomain: domain, jsonCompletionHandler: jsonCompletionHandler)
  }
  
  private func post(method method: String, jsonBody: String, jsonCompletionHandler: JSONCompletionHandler) {
    let domain = ErrorDomain.Parse + HTTPMethods.Post
    let url = NSURL(string: ParseClient.apiPath + method)!
    
    // 1. Create URL request
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = HTTPMethods.Post
    request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
    request.addValue(ParseClient.appID, forHTTPHeaderField: HTTPHeaderKeys.ParseApplicationID)
    request.addValue(ParseClient.apiKey, forHTTPHeaderField: HTTPHeaderKeys.ParseRESTAPIKey)
    request.addValue(HTTPHeaderValues.ApplicationJSON, forHTTPHeaderField: HTTPHeaderKeys.ContentType)
    
    // 2. Create data task
    self.dataTask(request, errorDomain: domain, jsonCompletionHandler: jsonCompletionHandler)
  }
  
  private func put(method method: String, jsonCompletionHandler: JSONCompletionHandler) {
    let domain = ErrorDomain.Parse + HTTPMethods.Put
    let url = NSURL(string: ParseClient.apiPath + method)!
    
    // 1. Create URL request
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = HTTPMethods.Put
    
    // 2. Create data task
    self.dataTask(request, errorDomain: domain, jsonCompletionHandler: jsonCompletionHandler)
  }
}

// Singleton
extension ParseClient {
  class func sharedInstance() -> ParseClient {
    struct Singleton {
      static var sharedInstance = ParseClient()
    }
    return Singleton.sharedInstance
  }
}