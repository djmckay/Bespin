//
//  EmailAddress.swift
//  App
//
//  Created by DJ McKay on 10/19/18.
//

import Foundation
import Vapor

public struct EmailAddress: Content {
    /// format: "Bob <bob@host.com>"
    public var email: String?
    
    public init(email: String,
                name: String? = nil) {
        self.email = "\(name ?? "") <\(email)>"
    }
}

extension Array where Element == EmailAddress {
    
    var stringArray: [String] {
        return map { entry -> String in
            return entry.email ?? ""
        }
    }
}


