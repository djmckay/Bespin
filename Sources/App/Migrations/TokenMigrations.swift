//
//  TokenMigrations.swift
//  App
//
//  Created by DJ McKay on 10/26/18.
//

import Vapor
import FluentMySQL
import Authentication

struct TokenAddUserRelationship: Migration {
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(Token.self, on: conn, closure: { (builder) in
            builder.reference(from: \.userID, to: \User.id)
        })
    }
    
    static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return .done(on: conn)
    }
    
    typealias Database = MySQLDatabase
    
    
}
