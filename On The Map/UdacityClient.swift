//
//  UdacityClient.swift
//  On The Map
//
//  Created by Shawn Burlew on 2/18/16.
//  Copyright © 2016 Shawn Burlew. All rights reserved.
//

import Foundation

private let session = NSURLSession.sharedSession()

class UdacityClient {
  
  // Udacity API
  private static let apiPath = "https://www.udacity.com/api"
  
  // Authentication
  private var sessionID: String?
  private var sessionExpiration: NSDate?
  
  // User data
  private var userID: String?
  private var facebookID: String?
  
  private func sendError(domain: String, message: String) -> NSError {
    return NSError(domain: "UdacityClient." + domain, code: 1, userInfo: [NSLocalizedDescriptionKey : message])
  }
  
  private func setUserID(id: String?) {
    ParseClient.sharedInstance().userID = id
  }
}

////////////////////////////////////////////////////////////////////////////////
// NETWORKING LEVEL 3 - INTERFACE METHODS
// 1. Call level 2 method with completion handler:
//   1. Check for errors from level 2
//   2. Handle data from level 2
//   3. Call external completion handler
////////////////////////////////////////////////////////////////////////////////
extension UdacityClient {
  
  func loginUdacity(withEmail email: String, password: String, completionHandler: (error: NSError?) -> Void) {
    
    // Create JSON object for authenticating session
    var jsonBody = "{\n"
    jsonBody += "  \"udacity\": {\n"
    jsonBody += "    \"username\": \"\(email)\",\n"
    jsonBody += "    \"password\": \"\(password)\"\n"
    jsonBody += "  }\n"
    jsonBody += "}"
    
    // 1. Call level 2 method
    // Authenticate session
    self.sessionPOST(jsonBody) { userID, sessionID, sessionExpiration, error in
      
      // 1. Check for errors
      // Validate authentication
      guard error == nil else {
        return completionHandler(error: error!)
      }
      
      // 2. Handle data
      self.userID = userID!
      self.sessionID = sessionID!
      self.sessionExpiration = NSDate.dateFromString(sessionExpiration!)
      
      // Get user data
      self.userGET { facebookID, error in
        
        // 1. Check for errors
        // Validate user data
        guard error == nil else {
          return completionHandler(error: error!)
        }
        
        // 2. Handle data
        self.facebookID = facebookID!
        
        // Set userID for Parse client
        ParseClient.sharedInstance()//setUserID
        
        // 3. Call external completion handler
        completionHandler(error: nil)
      }
    }
  }
  
  func logoutUdacity(completionHandler: (error: NSError?) -> Void) {
    
    // 1. Call level 2 method
    // Delete session
    self.sessionDELETE { error in
      
      // 1. Check for errors
      guard error == nil else {
        return completionHandler(error: error!)
      }
      
      // 2. Handle data
      self.sessionID = nil
      self.sessionExpiration = nil
      self.userID = nil
      self.facebookID = nil
      
      // Delete user ID from Parse client
      ParseClient.sharedInstance()//setUserID
      
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
extension UdacityClient {
  
  private func sessionDELETE(completionHandlerForSessionDELETE: (error: NSError?) -> Void) {
    
    // Delete session ID and log out.
    self.taskForDELETEMethod(UdacityMethods.Session) { error in
      
      // 1. Check for errors
      guard error == nil else {
        return completionHandlerForSessionDELETE(error: error!)
      }
      
      // 2. Construct JSON object from data
      // No JSON object necessary
      
      // 3. Parse through JSON object
      // No JSON object necessary
      
      // 4. Pass values up to level 3
      // No values need to be passed up
      completionHandlerForSessionDELETE(error: nil)
    }
  }
  
  private func userGET(completionHandler: (facebookID: String?, error: NSError?) -> Void) {
    let errorDomain = "userGET"
    
    // Construct method
    let method = UdacityMethods.User.stringByReplacingOccurrencesOfString(Placeholders.ID, withString: self.userID!)
    
    // 1. Call level 1 method
    self.taskForGETMethod(method) { data, error in
      
      // 1. Check for errors
      guard error == nil else {
        return completionHandler(facebookID: nil, error: error!)
      }
      
      // 2. Construct JSON object from data
      let parsedResult: AnyObject!
      do {
        parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
      } catch {
        return completionHandler(facebookID: nil, error: self.sendError(errorDomain, message: ErrorMessageKeys.ParseFailure))
      }
      
      // 3. Parse through JSON object
      // Get user dictionary
      guard let jsonUser = parsedResult[JSONResponseKeys.User] as? [String : AnyObject] else {
        return completionHandler(facebookID: nil, error: self.sendError(errorDomain, message: "Failed to retrieve user dictionary."))
      }
      
      // Get facebook ID
      guard let facebookID = jsonUser[JSONResponseKeys.FacebookID] as? String else {
        return completionHandler(facebookID: nil, error: self.sendError(errorDomain, message: "Failed to retrieve Facebook ID."))
      }
      
      // 4. Pass values up to level 3
      completionHandler(facebookID: facebookID, error: nil)
    }
  }
  
  private func sessionPOST(jsonBody: String, completionHandler: (userID: String?, sessionID: String?, sessionExpiration: String?, error: NSError?) -> Void) {
    let errorDomain = "UdacityClient.postToSession"
    
    // Construct method
    let method = UdacityMethods.Session
    
    // 1. Call level 1 method
    self.taskForPOSTMethod(method, jsonBody: jsonBody) { data, error in
      
      // 1. Check for errors
      guard error == nil else {
        return completionHandler(userID: nil, sessionID: nil, sessionExpiration: nil, error: error!)
      }
      
      // 2. Construct JSON object from data
      let parsedResult: AnyObject!
      do {
        parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
      } catch {
        return completionHandler(userID: nil, sessionID: nil, sessionExpiration: nil, error: self.sendError(errorDomain, message: ErrorMessageKeys.ParseFailure))
      }
      
      // 3. Parse through JSON object
      // Get account dictionary
      guard let jsonAccount = parsedResult[JSONResponseKeys.Account] as? [ String: AnyObject] else {
        return completionHandler(userID: nil, sessionID: nil, sessionExpiration: nil, error: self.sendError(errorDomain, message: "Failed to find user account information."))
      }
      
      // Get user ID
      guard let userID = jsonAccount[JSONResponseKeys.Key] as? String else {
        return completionHandler(userID: nil, sessionID: nil, sessionExpiration: nil, error: self.sendError(errorDomain, message: "Failed to find user ID."))
      }
      
      // Get session dictionary
      guard let jsonSession = parsedResult[JSONResponseKeys.Session] as? [String : AnyObject] else {
        return completionHandler(userID: nil, sessionID: nil, sessionExpiration: nil, error: self.sendError(errorDomain, message: "Failed to find session information."))
      }
      
      // Get session ID
      guard let sessionID = jsonSession[JSONResponseKeys.ID] as? String else {
        return completionHandler(userID: nil, sessionID: nil, sessionExpiration: nil, error: self.sendError(errorDomain, message: "Failed to find session ID."))
      }
      
      // Get session expiration
      guard let sessionExpiration = jsonSession[JSONResponseKeys.Expiration] as? String else {
        return completionHandler(userID: nil, sessionID: nil, sessionExpiration: nil, error: self.sendError(errorDomain, message: "Failed to find session expiration."))
      }
      
      // 4. Pass appropriate values up to level 3
      completionHandler(userID: userID, sessionID: sessionID, sessionExpiration: sessionExpiration, error: nil)
    }
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
extension UdacityClient {
  
  private func taskForDELETEMethod(method: String, completionHandlerForDELETE: (error: NSError?) -> Void) -> NSURLSessionDataTask {
    let errorDomain = "UdacityClient.taskForDELETEMethod"
    let url = NSURL(string: UdacityClient.apiPath + method)!
    
    // 1. Create URL request
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = HTTPMethods.Delete
    
    // Handle XSRF token
    var xsrfCookie: NSHTTPCookie?
    let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
    sharedCookieStorage.cookies!.flatMap {
      xsrfCookie = $0.name == "XSRF-TOKEN" ? $0 : nil
    }
    if let xsrfCookie = xsrfCookie {
      request.setValue(xsrfCookie.value, forHTTPHeaderField: HTTPHeaderKeys.XSRFToken)
    }
    
    // 2. Create data task
    let task = session.dataTaskWithRequest(request) { data, response, error in
      
      // 1. Check for errors
      guard error == nil else {
        return completionHandlerForDELETE(error: error!)
      }
      
      // 2. Check HTTP status code
      let httpResponse = response as! NSHTTPURLResponse
      guard httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 else {
        let message = ErrorMessageKeys.HTTPCode.stringByReplacingOccurrencesOfString("{code}", withString: "\(httpResponse.statusCode)")
        return completionHandlerForDELETE(error: self.sendError(errorDomain, message: message))
      }
      
      // 3. Validate data
      // No need to validate data as we only care that the request returned a
      // successful HTTP status code.
      
      // 4. Pass data up to level 2
      // No data needs to be passed up to level 2
      completionHandlerForDELETE(error: nil)
    }
    task.resume()
    return task
  }
  
  private func taskForGETMethod(method: String, completionHandlerForGET: (data: NSData?, error: NSError?) -> Void) -> NSURLSessionDataTask {
    let errorDomain = "UdacityClient.taskForGETMethod"
    let url = NSURL(string: UdacityClient.apiPath + method)!
    
    // 1. Create URL request
    let request = NSURLRequest(URL: url)
    
    // 2. Create data task
    let task = session.dataTaskWithRequest(request) { data, response, error in
      
      // 1. Check for errors
      guard error == nil else {
        return completionHandlerForGET(data: nil, error: error!)
      }
      
      // 2. Check HTTP status code
      let httpResponse = response as! NSHTTPURLResponse
      guard httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 else {
        let message = ErrorMessageKeys.HTTPCode.stringByReplacingOccurrencesOfString("{code}", withString: "\(httpResponse.statusCode)")
        return completionHandlerForGET(data: nil, error: self.sendError(errorDomain, message: message))
      }
      
      // 3. Validate data
      // Skip first 5 characters of data in conformance with Udacity's APIs
      guard let data = data?.subdataWithRange(NSRange.init(location: 5, length: (data?.length)! - 5)) else {
        return completionHandlerForGET(data: nil, error: self.sendError(errorDomain, message: ErrorMessageKeys.InvalidData))
      }
      
      // 4. Pass data up to level 2
      completionHandlerForGET(data: data, error: nil)
    }
    task.resume()
    return task
  }
  
  private func taskForPOSTMethod(method: String, jsonBody: String, completionHandlerForPOST: (data: NSData?, error: NSError?) -> Void) -> NSURLSessionDataTask {
    let errorDomain = "UdacityClient.taskForPOSTMethod"
    let url = NSURL(string: UdacityClient.apiPath + method)!
    
    // 1. Create URL request
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = HTTPMethods.Post
    request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
    request.addValue(HTTPHeaderValues.ApplicationJSON, forHTTPHeaderField: HTTPHeaderKeys.Accept)
    request.addValue(HTTPHeaderValues.ApplicationJSON, forHTTPHeaderField: HTTPHeaderKeys.ContentType)
    
    // 2. Create data task
    let task = session.dataTaskWithRequest(request) { data, response, error in
      
      // 1. Check for errors
      guard error == nil else {
        return completionHandlerForPOST(data: nil, error: self.sendError(errorDomain, message: "\(error!)"))
      }
      
      // 2. Check HTTP status code
      let httpResponse = response as! NSHTTPURLResponse
      guard httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 else {
        let message = ErrorMessageKeys.HTTPCode.stringByReplacingOccurrencesOfString("{code}", withString: "\(httpResponse.statusCode)")
        return completionHandlerForPOST(data: nil, error: self.sendError(errorDomain, message: message))
      }
      
      // 3. Validate data
      // Skip first 5 characters of data in conformance with Udacity's APIs
      guard let data = data?.subdataWithRange(NSRange.init(location: 5, length: (data?.length)! - 5)) else {
        return completionHandlerForPOST(data: nil, error: self.sendError(errorDomain, message: ErrorMessageKeys.InvalidData))
      }
      
      // 4. Pass data up to level 2
      completionHandlerForPOST(data: data, error: nil)
    }
    task.resume()
    return task
  }
}

// Singleton
extension UdacityClient {
  
  class func sharedInstance() -> UdacityClient {
    struct Singleton {
      static var sharedInstance = UdacityClient()
    }
    return Singleton.sharedInstance
  }
}