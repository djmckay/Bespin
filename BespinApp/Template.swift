//
//  Template.swift
//  BespinApp
//
//  Created by DJ McKay on 11/26/18.
//

import Foundation

struct Template: Codable {
    
    var id: UUID?
    var name: String
    var text: String
    var html: String
    var subject: String?
    var userID: UUID
    var from: String?
    var cc: String?
    var bcc: String?
    var replyTo: String?
    //var attachments: [Template.Attachment]? = []
    
    init(name: String, text: String, html: String, user: User, from: String? = nil, cc: String? = nil, bcc: String? = nil, replyTo: String? = nil) { //, attachments: [Attachment] = []) {
        self.name = name
        self.text = text
        self.html = html
        self.userID = user.id!
        self.from = from
        self.cc = cc
        self.bcc = bcc
        self.replyTo = replyTo
        //self.attachments = attachments
    }
    
    struct Attachment: Codable {
        var id: UUID?
        var templateID: UUID
        var filename: String
        var data: Data
        var path: String?
        
        init(filename: String, data: Data, template: Template) {
            self.filename = filename
            self.data = data
            self.templateID = template.id!
        }
    }
    
    
}


