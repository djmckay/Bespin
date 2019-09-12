//
//  User.swift
//  BespinApp
//
//  Created by DJ McKay on 11/25/18.
//

import Foundation

struct User: Codable {
    
    var id: UUID?
    var name: String
    var domain: String
    var username: String
    var password: String?
    
    init(name: String, domain: String, username: String, password: String? = nil) {
        self.name = name
        self.domain = domain
        self.username = username
        self.password = password
    }
    
    func getIDToken(completion: (String?, Error?) -> ()) {
        completion(self.id?.uuidString, nil)
    }
}
