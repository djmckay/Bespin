//
//  MailgunRouteSetup.swift
//  App
//
//  Created by DJ McKay on 10/19/18.
//

import Vapor
import Foundation

public struct RouteSetup: Content {
    public static var defaultContentType: MediaType = MediaType.urlEncodedForm
    
    public let priority: Int
    public let description: String
    public let filter: String
    public let action: [String]
    
    public init(forwardURL: String, description: String) {
        self.priority = 0
        self.description = description
        self.filter = "catch_all()"
        self.action = ["forward('\(forwardURL)')", "stop()"]
    }
    
    enum CodingKeys: String, CodingKey {
        case priority
        case description
        case filter = "expression"
        case action
    }
}
