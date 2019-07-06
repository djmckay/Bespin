//
//  EmailTemplateAttachmentsMigrations.swift
//  App
//
//  Created by DJ McKay on 7/4/19.
//

import Foundation
import Vapor
import FluentMySQL
import Authentication


struct AddEmailAttachmentPath: Migration {
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(EmailTemplateAttachment.self, on: conn, closure: { (builder) in
            builder.field(for: \.path)
        })
    }
    
    static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(EmailTemplateAttachment.self, on: conn, closure: { (builder) in
            builder.deleteField(for: \.path)
        })
    }
    
    typealias Database = MySQLDatabase
    
    
}

struct MakeDataOptional: Migration {
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(EmailTemplateAttachment.self, on: conn, closure: { (builder) in
            builder.field(for: \.data, type: .longtext, .notNull)
        })
    }
    
    static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.update(EmailTemplateAttachment.self, on: conn, closure: { (builder) in
            builder.deleteField(for: \.data)
        })
    }
    
    typealias Database = MySQLDatabase
    
    
}
