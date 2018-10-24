//
//  Bespin.swift
//  App
//
//  Created by DJ McKay on 10/20/18.
//

import Foundation
import Vapor
import FluentMySQL

struct Bespin {
    static fileprivate let DatabaseUsername: String = Environment.get("DATABASE_USER") ?? "bespin"
    static fileprivate let DatabasePassword: String = Environment.get("DATABASE_PASSWORD") ?? "password"
    
    static let BespinConfig = MySQLDatabaseConfig(hostname: "localhost", port: 3306, username: DatabaseUsername, password: DatabasePassword, database: "bespin")
    static let Bespin = MySQLDatabase(config: BespinConfig)
    
    static let BespinConfigTest = MySQLDatabaseConfig(hostname: "localhost", port: 3307, username: DatabaseUsername, password: DatabasePassword, database: "bespin-test")
    static let BespinTest = MySQLDatabase(config: BespinConfigTest)
}

extension DatabaseIdentifier {
    /// Default identifier for `MySQLDatabase`.
    public static var Bespin: DatabaseIdentifier<MySQLDatabase> {
        return .init("Bespin")
    }
}
