//
//  EmailTemplateAttachment.swift
//  App
//
//  Created by DJ McKay on 7/3/19.
//

import Foundation
import Vapor
import FluentMySQL
import Authentication

final class EmailTemplateAttachment: BespinModel {
    
    typealias Public = EmailTemplateAttachment

    var id: UUID?
    var templateID: EmailTemplate.ID
    var filename: String
    var data: Data
    
    init(filename: String, data: Data, templateID: EmailTemplate.ID) {
        self.filename = filename
        self.data = data
        self.templateID = templateID
    }
    
    func convertToPublic() -> EmailTemplateAttachment {
        return self
    }
}

extension EmailTemplateAttachment: Content {}
extension EmailTemplateAttachment: Migration {
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return MySQLDatabase.create(EmailTemplateAttachment.self, on: conn, closure: { (builder) in
            builder.field(for: \.id)
            builder.field(for: \.filename)
            builder.field(for: \.data)
            builder.field(for: \.templateID)
            //builder.reference(from: \.templateID, to: \EmailTemplate.id)
        })
    }
    
}


extension EmailTemplateAttachment: Parameter {}


extension Future where T: EmailTemplateAttachment {
    func convertToPublic() -> Future<EmailTemplateAttachment.Public> {
        return self.map(to: EmailTemplateAttachment.Public.self, { (user) -> EmailTemplateAttachment.Public in
            return user.convertToPublic()
        })
    }
}

//extension EmailTemplateAttachment {
//    var template: Parent<EmailTemplateAttachment, EmailTemplate> {
//        return parent(\.templateID)
//    }
//}
