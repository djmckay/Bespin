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
    
    init(name: String, text: String, html: String, userID: User.ID) {
        self.name = name
        self.text = text
        self.html = html
        self.userID = userID
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
