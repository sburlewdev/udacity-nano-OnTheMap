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
  static let NoUserKey = "User key not initialized"
  static let HTTPCode = "Returned HTTP status code " // + status code
  static let InvalidData = "Invalid data"
  static let ParseFailure = "Failed to parse data"
  static let FindFailure = "Failed to find " // + element
  static let Unknown = "Unknown error"
}

// Error Domain Values
struct ErrorDomain {
  static let Udacity = "UdacityClient."
  static let Parse = "ParseClient."
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
  static let PResultsArray = "results"
  static let PCreatedAt = "createdAt"
  static let PFirstName = "firstName"
  static let PLastName = "lastName"
  static let PLatitude = "latitude"
  static let PLongitude = "longitude"
  static let PMapString = "mapString"
  static let PMediaURL = "mediaURL"
  static let PObjectID = "objectId"
  static let PUniqueKey = "uniqueKey"
  static let PUpdatedAt = "updatedAt"
  
  // Udacity
  // Authentication
  static let USessionDict = "session"
  static let USessionExpiration = "expiration"
  static let USessionID = "id"
  
  // User data
  static let UAccountDict = "account"
  static let UUserKey = "key"
  static let URegistered = "registered"
  static let UUserDict = "user"
  static let UFirstName = "first_name"
  static let ULastName = "last_name"
  static let UEmailDict = "email"
  static let UEmailAddress = "address"
  static let UFacebookID = "_facebook_id"
}

// Methods
struct ParseMethods {
  static let StudentLocation = "/classes/StudentLocation"
}

struct UdacityMethods {
  static let Session = "/session"
  static let User = "/users/" // + user ID
}