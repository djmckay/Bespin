//
//  EmailTemplate.swift
//  App
//
//  Created by DJ McKay on 10/19/18.
//

import Foundation
import Vapor
import FluentMySQL
import Authentication

final class EmailTemplate: BespinModel {
    
    typealias Public = EmailTemplate
    
    
    var id: UUID?
    var name: String
    var text: String
    var html: String
    var subject: String?
    var userID: User.ID
    var from: String?
    var cc: String?
    var bcc: String?
    var replyTo: String?
    
    init(name: String, text: String, html: String, userID: User.ID, from: String? = nil, cc: String? = nil, bcc: String? = nil, replyTo: String? = nil) {
        self.name = name
        self.text = text
        self.html = html
        self.userID = userID
        self.from = from
        self.cc = cc
        self.bcc = bcc
        self.replyTo = replyTo
    }
    
    func convertToPublic() -> EmailTemplate {
        return self
    }
    
}

extension EmailTemplate: Content {}
extension EmailTemplate: Migration {
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.create(EmailTemplate.self, on: conn, closure: { (builder) in
            builder.field(for: \.id)
            builder.field(for: \.name)
            builder.field(for: \.text, type: .longtext)
            builder.field(for: \.html, type: .longtext)
            builder.field(for: \.subject)
            builder.field(for: \.userID)
            builder.reference(from: \.userID, to: \User.id)
            builder.field(for: \.from)
            builder.field(for: \.cc)
            builder.field(for: \.bcc)
            builder.field(for: \.replyTo)
        })
    }
    
}
extension EmailTemplate: Parameter {}


extension Future where T: EmailTemplate {
    func convertToPublic() -> Future<EmailTemplate.Public> {
        return self.map(to: EmailTemplate.Public.self, { (user) -> EmailTemplate.Public in
            return user.convertToPublic()
        })
    }
}

extension EmailTemplate {
    var attachments: Children<EmailTemplate, EmailTemplateAttachment> {
        return children(\.templateID)
    }
}
