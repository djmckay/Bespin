//
//  EmailTemplateMigrations.swift
//  App
//
//  Created by DJ McKay on 10/22/18.
//

import Foundation
import Vapor
import FluentMySQL
import Authentication

struct RemoveTextHtmlColumn: Migration {
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(EmailTemplate.self, on: conn, closure: { (builder) in
            builder.deleteField(for: \.text)
            builder.deleteField(for: \.html)
        })
    }
    
    static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(EmailTemplate.self, on: conn, closure: { (builder) in
            builder.deleteField(for: \.text)
            builder.deleteField(for: \.html)
        })
    }
    
    typealias Database = MySQLDatabase
    
    
}

struct AddTextHtmlColumnAsLongText: Migration {
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(EmailTemplate.self, on: conn, closure: { (builder) in
            builder.field(for: \.text, type: .longtext)
            builder.field(for: \.html, type: .longtext)
        })
    }
    
    static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(EmailTemplate.self, on: conn, closure: { (builder) in
            builder.deleteField(for: \.text)
            builder.deleteField(for: \.html)
        })
    }
    
    typealias Database = MySQLDatabase
    
    
}


