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

// All networking clients should adopt this protocol
protocol NetworkClient {
  func dataTask(request: NSURLRequest, errorDomain: String, jsonCompletionHandler: JSONCompletionHandler) -> NSURLSessionDataTask
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
        let message = ErrorMessageKeys.HTTPCode.stringByReplacingOccurrencesOfString(Placeholders.HTTPCode, withString: "\(httpResponse.statusCode)")
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
}

extension NSError {
  class func getError(withDomain domain: String, message: String) -> NSError {
    return NSError(domain: domain, code: 1, userInfo: [NSLocalizedDescriptionKey : message])
  }
}