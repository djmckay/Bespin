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

struct EmailTemplateAddUserRelationship: Migration {
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(EmailTemplate.self, on: conn, closure: { (builder) in
            builder.field(for: \.userID)
            builder.reference(from: \.userID, to: \User.id)
        })
    }
    
    static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(EmailTemplate.self, on: conn, closure: { (builder) in
            builder.deleteField(for: \.userID)
        })
    }
    
    typealias Database = MySQLDatabase
    
    
}

struct EmailTemplateAddEmailFields: Migration {
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(EmailTemplate.self, on: conn, closure: { (builder) in
            builder.field(for: \.from)
            builder.field(for: \.cc)
            builder.field(for: \.bcc)
            builder.field(for: \.replyTo)
        })
    }
    
    static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(EmailTemplate.self, on: conn, closure: { (builder) in
            builder.deleteField(for: \.from)
            builder.deleteField(for: \.cc)
            builder.deleteField(for: \.bcc)
            builder.deleteField(for: \.replyTo)
        })
    }
    
    typealias Database = MySQLDatabase
    
    
}


