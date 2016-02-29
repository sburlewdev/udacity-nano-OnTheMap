//
//  Client.swift
//  On The Map
//
//  Created by Shawn Burlew on 2/26/16.
//  Copyright © 2016 Shawn Burlew. All rights reserved.
//

import Foundation

////////////////////////////////////////////////////////////////////////////////
// NETWORKING LEVEL 0 - DATA TASK
// 1. Check for errors
// 2. Check HTTP status code
// 3. Validate data
////////////////////////////////////////////////////////////////////////////////

private let session = NSURLSession.sharedSession()

// Type Aliases
// WARNING: The "typealias" keyword will be deprecated in Swift 2.2
// https://github.com/apple/swift-evolution/blob/master/proposals/0011-replace-typealias-associated.md
typealias BasicCompletionHandler = (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void
typealias JSONCompletionHandler = (data: NSData!, error: NSError?) -> Void
typealias JSON = [String : AnyObject]

// All networking clients should adopt this protocol
protocol NetworkClient {
  func dataTask(request: NSURLRequest, errorDomain: String, jsonCompletionHandler: JSONCompletionHandler) -> NSURLSessionDataTask
  func substituteParameters(forJSON json: JSON) -> String
}

// Provide implementation for all networking clients who adopt NetworkClient
extension NetworkClient {

  func dataTask(request: NSURLRequest, errorDomain: String, jsonCompletionHandler: JSONCompletionHandler) -> NSURLSessionDataTask {
    // Basic completion handler for all URL requests
    let basicHandler: BasicCompletionHandler = { data, response, error in
      
      // 1. Check for errors
      guard error == nil else {
        return jsonCompletionHandler(data: nil, error: error!)
      }
      
      // 2. Check HTTP status code
      let httpResponse = response as! NSHTTPURLResponse
      guard httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 else {
        let message = ErrorMessageKeys.HTTPCode + "\(httpResponse.statusCode)"
        return jsonCompletionHandler(data: nil, error: NSError.getError(withDomain: errorDomain, message: message))
      }
      
      // 3. Validate data
      guard let data = data else {
        return jsonCompletionHandler(data: nil, error: NSError.getError(withDomain: errorDomain, message: ErrorMessageKeys.InvalidData))
      }
      
      jsonCompletionHandler(data: data, error: nil)
    } // basicHandler
    
    let task = session.dataTaskWithRequest(request, completionHandler: basicHandler)
    task.resume()
    return task
  }
  
  func substituteParameters(forJSON json: JSON) -> String {
    var paramString = "?"
    for param in json {
      if let value = param.1 as? String {
        paramString += "\(param.0)=\(value)&"
      }
    }
    if paramString == "?" {
      return ""
    } else {
      // Remove "&" at end of string
      return paramString.substringToIndex(paramString.endIndex.predecessor())
    }
  }
}

extension NSError {
  class func getError(withDomain domain: String, message: String) -> NSError {
    return NSError(domain: domain, code: 1, userInfo: [NSLocalizedDescriptionKey : domain + " : " + message])
  }
}