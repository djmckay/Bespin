//
//  Token.swift
//  BespinApp
//
//  Created by DJ McKay on 11/25/18.
//

import Foundation

class Token: Codable {
    
    var id: UUID?
    var token: String
    var userID: UUID
    
    init(token: String, user: User) {
        self.token = token
        self.userID = user.id!
    }
}
