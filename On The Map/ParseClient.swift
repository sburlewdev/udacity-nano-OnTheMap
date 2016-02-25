//
//  ParseClient.swift
//  On The Map
//
//  Created by Shawn Burlew on 2/18/16.
//  Copyright © 2016 Shawn Burlew. All rights reserved.
//

import Foundation

private let session = NSURLSession.sharedSession()

class ParseClient {
  
  // App & API keys
  private static let appID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
  private static let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
  
  // Parse API Path
  private static let apiPath = "https://api.parse.com/1"
  
  // User ID
  var userID: String!
  
  // Student location data for display
  private (set) var studentLocations = [StudentInformation]()
  
  private func sendError(domain: String, message: String) -> NSError {
    return NSError(domain: "ParseClient." + domain, code: 1, userInfo: [NSLocalizedDescriptionKey : message])
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
  
  func getStudentLocations(completionHandler: (error: NSError?) -> Void) {
    
    // 1. Call level 2 method
    self.studentLocationGET { jsonLocations, error in
      
      // 1. Check for errors
      guard error == nil else {
        return completionHandler(error: error!)
      }
      
      // 2. Handle data
      self.studentLocations.removeAll()
      for location in jsonLocations! {
        self.studentLocations.append(StudentInformation(dictionary: location))
      }
      self.studentLocations.sortInPlace { NSDate.stringFromDate($0.0.createdAt) > NSDate.stringFromDate($0.1.createdAt) }
      
      // 3. Call external completion handler
      completionHandler(error: nil)
    }
  }
  
  func createStudentLocation() {
    
  }
  
  func updateStudentLocation() {
    
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
  
  private func studentLocationGET(completionHandler: (jsonLocations: [[String : AnyObject]]?, error: NSError?) -> Void) {
    let errorDomain = "studentLocationGET"
    
    // 1. Call level 1 method
    self.taskForGETMethod(ParseMethods.StudentLocation) { data, error in
      
      // 1. Check for errors
      guard error == nil else {
        return completionHandler(jsonLocations: nil, error: self.sendError(errorDomain, message: "\(error!)"))
      }
      
      // 2. Construct JSON object from data
      let parsedResult: AnyObject!
      do {
        parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
      } catch {
        return completionHandler(jsonLocations: nil, error: self.sendError(errorDomain, message: ErrorMessageKeys.ParseFailure))
      }
      
      // 3. Parse through JSON object
      guard let jsonLocations = parsedResult["results"] as? [[String : AnyObject]] else {
        return completionHandler(jsonLocations: nil, error: self.sendError(errorDomain, message: "Failed to retrieve results dictionary in JSON object."))
      }
      
      // 4. Pass appropriate values up to level 3
      completionHandler(jsonLocations: jsonLocations, error: nil)
    }
  }
  
  private func studentLocationPOST(completionHandler: (data: NSData?, error: NSError?) -> Void) {
    let errorDomain = "studentLocationPost"
    
    var jsonBody = "{\n"
    jsonBody += "  \"\(JSONResponseKeys.UniqueKey)\": \"blergh!!\",\n"
    jsonBody += "  \"\(JSONResponseKeys.FirstName)\": \"test\",\n"
    jsonBody += "  \"\(JSONResponseKeys.LastName)\": \"bros\",\n"
    jsonBody += "  \"\(JSONResponseKeys.MapString)\": \"Somewhere Over the Rainbow\",\n"
    jsonBody += "  \"\(JSONResponseKeys.MediaURL)\": \"www.realm.io\",\n"
    jsonBody += "  \"\(JSONResponseKeys.Latitude)\": 5.0,\n"
    jsonBody += "  \"\(JSONResponseKeys.Longitude)\": 1.0\n"
    jsonBody += "}"
    
    // 1. Call level 1 method
    taskForPOSTMethod(ParseMethods.StudentLocation, jsonBody: jsonBody) { data, error in
      
      // 1. Check for errors
      guard error == nil else {
        return completionHandler(data: nil, error: error!)
      }
      
      // 2. Construct JSON object from data
      let parsedResult: AnyObject!
      do {
        parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
      } catch {
        return completionHandler(data: nil, error: self.sendError(errorDomain, message: ErrorMessageKeys.ParseFailure))
      }
      
      // 3. Parse through JSON object
      
      // 4. Pass appropriate values up to level 3
      completionHandler(data: nil, error: nil)
    }
  }
  
  private func studentLocationPUT() {
    
  }
}

////////////////////////////////////////////////////////////////////////////////
// NETWORKING LEVEL 1 - DATA TASKS
// 1. Create URL request with method (and JSON body)
// 2. Create data task with completion handler:
//   1. Check for errors
//   2. Check HTTP status code
//   3. Validate data
//   4. Pass data up to level 2
////////////////////////////////////////////////////////////////////////////////
extension ParseClient {
  
  private func taskForGETMethod(method: String, /*methodParameters: [String : AnyObject],*/ completionHandler: (data: NSData?, error: NSError?) -> Void) -> NSURLSessionDataTask {
    let errorDomain = "taskForGETMethod"
    let url = NSURL(string: ParseClient.apiPath + method + "?limit=100")!
    
    // 1. Create url request
    let request = NSMutableURLRequest(URL: url)
    request.addValue(ParseClient.appID, forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue(ParseClient.apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
    
    // 2. Create data task
    let task = session.dataTaskWithRequest(request) { data, response, error in
      
      // 1. Check for errors
      guard error == nil else {
        return completionHandler(data: nil, error: self.sendError(errorDomain, message: "\(error!)"))
      }
      
      // 2. Check HTTP status code
      let statusCode = (response as! NSHTTPURLResponse).statusCode
      guard statusCode >= 200 && statusCode <= 299 else {
        return completionHandler(data: nil, error: self.sendError(errorDomain, message: "Returned status code \(statusCode)."))
      }
      
      // 3. Validate data
      guard let data = data else {
        return completionHandler(data: nil, error: self.sendError(errorDomain, message: ErrorMessageKeys.InvalidData))
      }
      
      // 4. Pass data up to level 2
      completionHandler(data: data, error: nil)
      
      //self.basicHandling((data, response, error), completionHandler: completionHandler)
    }
    task.resume()
    
    return task
  }
  
  private func taskForPOSTMethod(method: String, jsonBody: String, completionHandler: (data: NSData?, error: NSError?) -> Void) -> NSURLSessionDataTask {
    let errorDomain = "taskForPOSTMethod"
    let url = NSURL(string: ParseClient.apiPath + method)!
    
    // 1. Create URL request
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = HTTPMethods.Post
    request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
    request.addValue(ParseClient.appID, forHTTPHeaderField: HTTPHeaderKeys.ParseApplicationID)
    request.addValue(ParseClient.apiKey, forHTTPHeaderField: HTTPHeaderKeys.ParseRESTAPIKey)
    request.addValue(HTTPHeaderValues.ApplicationJSON, forHTTPHeaderField: HTTPHeaderKeys.ContentType)
    
    // 2. Create data task
    let task = session.dataTaskWithRequest(request) { data, response, error in
      
      // 1. Check for errors
      guard error == nil else {
        return completionHandler(data: nil, error: error!)
      }
      
      // 2. Check HTTP status code
      let statusCode = (response as! NSHTTPURLResponse).statusCode
      guard statusCode >= 200 && statusCode <= 299 else {
        return completionHandler(data: nil, error: self.sendError(errorDomain, message: "Returned status code \(statusCode)."))
      }
      
      // 3. Validate data
      guard let data = data else {
        return completionHandler(data: nil, error: self.sendError(errorDomain, message: ErrorMessageKeys.InvalidData))
      }
      
      // 4. Pass data up to level 2
      completionHandler(data: data, error: nil)
    }
    task.resume()
    return task
  }
  
  private func taskForPUTMethod(method: String, completionHandler: (data: NSData?, error: NSError?) -> Void) -> NSURLSessionDataTask {
    let errorDomain = "taskForPUTMethod"
    let url = NSURL(string: ParseClient.apiPath + method)!
    
    // 1. Create URL request
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = HTTPMethods.Put
    
    let task = session.dataTaskWithRequest(request) { data, response, error in
      
      // 1. Check for errors
      guard error == nil else {
        return completionHandler(data: nil, error: error!)
      }
      
      // 2. Check HTTP status code
      let statusCode = (response as! NSHTTPURLResponse).statusCode
      guard statusCode >= 200 && statusCode <= 299 else {
        return completionHandler(data: nil, error: self.sendError(errorDomain, message: "Returned status code \(statusCode)."))
      }
      
      // 3. Validate data
      guard let data = data else {
        return completionHandler(data: nil, error: self.sendError(errorDomain, message: ErrorMessageKeys.InvalidData))
      }
      
      // 4. Pass data up to level 2
      completionHandler(data: data, error: nil)
    }
    task.resume()
    return task
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