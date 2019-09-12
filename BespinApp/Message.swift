//
//  Message.swift
//  BespinApp
//
//  Created by DJ McKay on 11/27/18.
//

import Foundation
struct Message: Codable {
    
    struct Address: Codable {
        public var email: String?
        public var name: String?
        
        public init(email: String,
                    name: String? = nil) {
            self.name = name
            self.email = email
        }
    }
    
    public struct EmailAttachment: Codable {
        
        
        /// Name of the file, including extension.
        public var filename: String
        
        /// The file's data.
        public var data: Data
        
        /// Associated `MediaType` for this file's extension, if it has one.
        public var contentType: MediaType? {
            return ext.flatMap { MediaType.fileExtension($0.lowercased()) }
        }
        
        /// The file extension, if it has one.
        public var ext: String? {
            return filename.split(separator: ".").last.map(String.init)
        }
        
        /// Creates a new `File`.
        ///
        ///     let file = File(data: "hello", filename: "foo.txt")
        ///
        /// - parameters:
        ///     - data: The file's contents.
        ///     - filename: The name of the file, not including path.
        public init(data: Data, filename: String) {
            self.data = data
            self.filename = filename
        }
    }
    
    public var to: [Address]?
    
    public var from: Address?
    
    public var cc: [Address]?
    
    public var bcc: [Address]?
    
    public var replyTo: Address?
    
    /// The global, or “message level”, subject of your email. This may be overridden by personalizations[x].subject.
    public var subject: String?
    
    /// An array in which you may specify the content of your email.
    public var text: String?
    public var html: String?
    
    /// An array of objects in which you can specify any attachments you want to include.
    public var attachments: [EmailAttachment]?
    public var deliveryTime: Date?
    public var testmode: Bool?
    
    public typealias RecipientVariables = [String: [String: String]]
    
    public var recipientVariables: RecipientVariables?
    public var template: String?
    
    public enum CodingKeys: String, CodingKey {
        case from
        case replyTo = "h:Reply-To"
        case to
        case cc
        case bcc
        case text
        case html
        case subject
        case attachments = "attachment"
        case recipientVariables = "recipient-variables"
        case template
        case deliveryTime
        case testmode
    }
    
    init() {
        
    }
    public struct MessageResponse: Codable {
        /// messsage
        public let message: String
        public let id: String
    }
}

extension Array where Element == Message.Address {
    
    var stringArray: [String] {
        return map { entry -> String in
            return entry.email ?? ""
        }
    }
}
