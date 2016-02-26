//
//  Constants.swift
//  On The Map
//
//  Created by Shawn Burlew on 2/23/16.
//  Copyright © 2016 Shawn Burlew. All rights reserved.
//

import Foundation

// Error Message Keys
struct ErrorMessageKeys {
  static let HTTPCode = "Returned HTTP status code " // + status code
  static let InvalidData = "Invalid data."
  static let ParseFailure = "Failed to parse data."
  static let FindFailure = "Failed to find " // + element
}

// HTTP Request Header Keys
struct HTTPHeaderKeys {
  static let Accept = "Accept"
  static let ContentType = "Content-Type"
  static let ParseApplicationID = "X-Parse-Application-Id"
  static let ParseRESTAPIKey = "X-Parse-REST-API-Key"
  static let XSRFToken = "X-XSRF-TOKEN"
}

// HTTP Request Header Values
struct HTTPHeaderValues {
  static let ApplicationJSON = "application/json"
}

// HTTP Methods
struct HTTPMethods {
  static let Get = "GET"
  static let Post = "POST"
  static let Delete = "DELETE"
  static let Put = "PUT"
}

// JSON Response Keys
struct JSONResponseKeys {
  // Parse
  // Student location
  static let CreatedAt = "createdAt"
  static let FirstName = "firstName"
  static let LastName = "lastName"
  static let Latitude = "latitude"
  static let Longitude = "longitude"
  static let MapString = "mapString"
  static let MediaURL = "mediaURL"
  static let ObjectID = "objectId"
  static let UniqueKey = "uniqueKey"
  static let UpdatedAt = "updatedAt"
  
  // Udacity
  // Authentication
  static let Session = "session"
  static let SessionExpiration = "expiration"
  static let SessionID = "id"
  
  // User data
  static let Account = "account"
  static let UserKey = "key"
  static let Registered = "registered"
  static let User = "user"
  static let Email = "email"
  static let EmailAddress = "address"
  static let FacebookID = "_facebook_id"
}

// Methods
struct ParseMethods {
  static let StudentLocation = "/classes/StudentLocation"
}

struct UdacityMethods {
  static let Session = "/session"
  static let User = "/users/" // + user ID
}