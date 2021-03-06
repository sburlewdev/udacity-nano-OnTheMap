//
//  UdacityClient.swift
//  On The Map
//
//  Created by Shawn Burlew on 2/18/16.
//  Copyright © 2016 Shawn Burlew. All rights reserved.
//

import Foundation

class UdacityClient {
  
  // Udacity API
  private static let apiPath = "https://www.udacity.com/api"
  
  // Authentication
  private var sessionID: String!
  private var sessionExpiration: NSDate!
  
  // User data
  private var facebookID: String!
  
  private func reset() {
    self.sessionID = nil
    self.sessionExpiration = nil
    self.facebookID = nil
  }
  
  func loginFacebook(withAccessToken token: String, completionHandler: (error: NSError?) -> Void) {
    var facebookJSON = "{\n"
    facebookJSON += "  \"facebook_mobile\": {\n"
    facebookJSON += "    \"access_token\": \"\(token)\"\n"
    facebookJSON += "  }\n"
    facebookJSON += "}"
    
    self.login(facebookJSON, completionHandler: completionHandler)
  }
  
  func loginUdacity(withEmail email: String, password: String, completionHandler: (error: NSError?) -> Void) {
    
    // Construct JSON object for authenticating session
    var udacityJSON = "{\n"
    udacityJSON += "  \"udacity\": {\n"
    udacityJSON += "    \"username\": \"\(email)\",\n"
    udacityJSON += "    \"password\": \"\(password)\"\n"
    udacityJSON += "  }\n"
    udacityJSON += "}"
    
    self.login(udacityJSON, completionHandler: completionHandler)
  }
}

////////////////////////////////////////////////////////////////////////////////
// NETWORKING LEVEL 3 - INTERFACE METHODS
// 1. Call level 2 method with completion handler:
//   1. Check for errors
//   2. Handle data
//   3. Call external completion handler
////////////////////////////////////////////////////////////////////////////////
extension UdacityClient {
  
  private func login(jsonBody: String, completionHandler: (error: NSError?) -> Void) {
    // 1. Authenticate session
    self.authenticateSession(jsonBody) { sessionInfo, error in
      
      // 1. Check for errors
      // Validate authentication
      guard error == nil else {
        return completionHandler(error: error!)
      }
      
      // 2. Handle data
      let userKey = (sessionInfo[JSONResponseKeys.UUserKey] as! String)
      self.sessionID = (sessionInfo[JSONResponseKeys.USessionID] as! String)
      self.sessionExpiration = NSDate.dateFromString(sessionInfo[JSONResponseKeys.USessionExpiration] as! String)
      
      // Get user info
      self.getUserInfo(userKey) { userInfo, error in
        
        // 1. Check for errors
        // Validate user data
        guard error == nil else {
          return completionHandler(error: error!)
        }
        
        // 2. Handle data
        let firstName = (userInfo[JSONResponseKeys.UFirstName] as! String)
        let lastName = (userInfo[JSONResponseKeys.ULastName] as! String)
        self.facebookID = (userInfo[JSONResponseKeys.UFacebookID] as! String)
        
        // Set user info for Parse client
        let userInfo: JSON = [
          JSONResponseKeys.USessionID : self.sessionID,
          JSONResponseKeys.UUserKey : userKey,
          JSONResponseKeys.UFirstName : firstName,
          JSONResponseKeys.ULastName : lastName
        ]
        ParseClient.sharedInstance().setUserInfo(userInfo)
        
        // 3. Call external completion handler
        completionHandler(error: nil)
      }
    }
  }
  
  func logoutUdacity(completionHandler: (error: NSError?) -> Void) {
    let domain = ErrorDomain.Udacity + "logoutUdacity"
    
    // 1. Call level 2 method
    self.deleteSession { error in
      
      // 1. Check for errors
      guard error == nil else {
        return completionHandler(error: error!)
      }
      
      // 2. Handle data
      guard ParseClient.sharedInstance().reset(self.sessionID) == true else {
        return completionHandler(error: NSError.getError(withDomain: domain, message: "Failed to clear Parse data"))
      }
      
      self.reset()
      
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
  
  private func deleteSession(completionHandler: (error: NSError?) -> Void) {
    
    // Delete session ID and log out.
    self.delete(UdacityMethods.Session) { data, error in
      
      // 1. Check for errors
      guard error == nil else {
        return completionHandler(error: error!)
      }
      
      // 2. Construct JSON object from data
      // No JSON object necessary
      
      // 3. Parse through JSON object
      // No JSON object necessary
      
      // 4. Pass values up
      // No values need to be passed up
      completionHandler(error: nil)
    }
  }
  
  private func getUserInfo(userKey: String, completionHandler: (userInfo: JSON!, error: NSError?) -> Void) {
    let domain = ErrorDomain.Udacity + "getUserInfo"
    
    // 1. Call level 1 method
    self.get(UdacityMethods.User + userKey) { data, error in
      
      // 1. Check for errors
      guard error == nil else {
        return completionHandler(userInfo: nil, error: error!)
      }
      
      // 2. Construct JSON object from data
      // Skip first 5 characters as required by Udacity API
      let data = data.subdataWithRange(NSRange.init(location: 5, length: (data.length) - 5))
      let parsedResult: AnyObject!
      do {
        parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
      } catch {
        return completionHandler(userInfo: nil, error: NSError.getError(withDomain: domain, message: ErrorMessageKeys.ParseFailure))
      }
      
      // 3. Parse through JSON object
      // Get user dictionary
      guard let user = parsedResult[JSONResponseKeys.UUserDict] as? JSON else {
        return completionHandler(userInfo: nil, error: NSError.getError(withDomain: domain, message: ErrorMessageKeys.FindFailure + "user dictionary"))
      }
      
      // Get first name
      guard let firstName = user[JSONResponseKeys.UFirstName] else {
        return completionHandler(userInfo: nil, error: NSError.getError(withDomain: domain, message: ErrorMessageKeys.FindFailure + "first name"))
      }
      
      // Get last name
      guard let lastName = user[JSONResponseKeys.ULastName] else {
        return completionHandler(userInfo: nil, error: NSError.getError(withDomain: domain, message: ErrorMessageKeys.FindFailure + "last name"))
      }
      
      // Get facebook ID
      guard let facebookID = user[JSONResponseKeys.UFacebookID] else {
        return completionHandler(userInfo: nil, error: NSError.getError(withDomain: domain, message: ErrorMessageKeys.FindFailure + "Facebook ID"))
      }
      
      let userInfo: JSON = [
        JSONResponseKeys.UFacebookID : facebookID,
        JSONResponseKeys.UFirstName : firstName,
        JSONResponseKeys.ULastName : lastName
      ]
      
      // 4. Pass user info up
      completionHandler(userInfo: userInfo, error: nil)
    }
  }
  
  private func authenticateSession(jsonBody: String, completionHandler: (sessionInfo: JSON!, error: NSError?) -> Void) {
    let domain = ErrorDomain.Udacity + "authenticateSession"
    
    // 1. Call level 1 method
    self.post(UdacityMethods.Session, jsonBody: jsonBody) { data, error in
      
      // 1. Check for errors
      guard error == nil else {
        return completionHandler(sessionInfo: nil, error: error!)
      }

      // 2. Construct JSON object from data
      // Skip first 5 characters as required by Udacity API
      let data = data.subdataWithRange(NSRange.init(location: 5, length: (data.length) - 5))
      let parsedResult: AnyObject!
      do {
        parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
      } catch {
        return completionHandler(sessionInfo: nil, error: NSError.getError(withDomain: domain, message: ErrorMessageKeys.ParseFailure))
      }
      
      // 3. Parse through JSON object
      // Get account dictionary
      guard let jsonAccount = parsedResult[JSONResponseKeys.UAccountDict] as? JSON else {
        return completionHandler(sessionInfo: nil, error: NSError.getError(withDomain: domain, message: ErrorMessageKeys.FindFailure + "user account dictionary"))
      }
      
      // Get user ID
      guard let userKey = jsonAccount[JSONResponseKeys.UUserKey] else {
        return completionHandler(sessionInfo: nil, error: NSError.getError(withDomain: domain, message: ErrorMessageKeys.FindFailure + "user key"))
      }
      
      // Get session dictionary
      guard let jsonSession = parsedResult[JSONResponseKeys.USessionDict] as? JSON else {
        return completionHandler(sessionInfo: nil, error: NSError.getError(withDomain: domain, message: ErrorMessageKeys.FindFailure + "session dictionary"))
      }
      
      // Get session ID
      guard let sessionID = jsonSession[JSONResponseKeys.USessionID] else {
        return completionHandler(sessionInfo: nil, error: NSError.getError(withDomain: domain, message: ErrorMessageKeys.FindFailure + "session ID"))
      }
      
      // Get session expiration
      guard let sessionExpiration = jsonSession[JSONResponseKeys.USessionExpiration] else {
        return completionHandler(sessionInfo: nil, error: NSError.getError(withDomain: domain, message: ErrorMessageKeys.FindFailure + "session expiration"))
      }
      
      let sessionInfo: JSON = [
        JSONResponseKeys.USessionID : sessionID,
        JSONResponseKeys.USessionExpiration : sessionExpiration,
        JSONResponseKeys.UUserKey : userKey
      ]
      
      // 4. Pass session info up
      completionHandler(sessionInfo: sessionInfo, error: nil)
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
// NETWORKING LEVEL 1 - URL REQUESTS
// 1. Create URL request with method (and JSON body)
// 2. Create data task, pass in JSONCompletionHandler
////////////////////////////////////////////////////////////////////////////////
extension UdacityClient: NetworkClient {
  
  private func delete(method: String, jsonCompletionHandler: JSONCompletionHandler) {
    let domain = ErrorDomain.Udacity + HTTPMethods.Delete
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
    self.dataTask(request, errorDomain: domain, jsonCompletionHandler: jsonCompletionHandler)
  }
  
  private func get(method: String, jsonCompletionHandler: JSONCompletionHandler) {
    let domain = ErrorDomain.Udacity + HTTPMethods.Get
    let url = NSURL(string: UdacityClient.apiPath + method)!
    
    // 1. Create URL request
    let request = NSURLRequest(URL: url)
    
    // 2. Create data task
    self.dataTask(request, errorDomain: domain, jsonCompletionHandler: jsonCompletionHandler)
  }
  
  private func post(method: String, jsonBody: String, jsonCompletionHandler: JSONCompletionHandler) {
    let domain = ErrorDomain.Udacity + HTTPMethods.Post
    let url = NSURL(string: UdacityClient.apiPath + method)!
    
    // 1. Create URL request
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = HTTPMethods.Post
    request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
    request.addValue(HTTPHeaderValues.ApplicationJSON, forHTTPHeaderField: HTTPHeaderKeys.Accept)
    request.addValue(HTTPHeaderValues.ApplicationJSON, forHTTPHeaderField: HTTPHeaderKeys.ContentType)
    
    // 2. Create data task
    self.dataTask(request, errorDomain: domain, jsonCompletionHandler: jsonCompletionHandler)
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