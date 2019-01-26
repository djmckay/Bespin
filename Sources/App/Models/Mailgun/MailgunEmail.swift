//
//  MailgunEmail.swift
//  App
//
//  Created by DJ McKay on 10/19/18.
//

import Foundation
import Vapor

public protocol MailgunEmailType: Content {
    var to: String? { get set }
    
    var from: String? { get set }
    
    var cc: String? { get set }
    
    var bcc: String? { get set }
    
    var replyTo: String? { get set }
    
    /// The global, or “message level”, subject of your email. This may be overridden by personalizations[x].subject.
    var subject: String? { get set }
    
    /// An array in which you may specify the content of your email.
    var text: String? { get set }
    var html: String? { get set }
    
    /// An array of objects in which you can specify any attachments you want to include.
    var attachments: [EmailAttachment]? { get set }
    var recipientVariables: String? { get set }
    var deliveryTime: String? { get set }
}

public struct MailgunEmail: MailgunEmailType {
    
    public static var defaultContentType: MediaType = MediaType.formData
    
    /// An array of messages and their metadata. Each object within personalizations can be thought of as an envelope - it defines who should receive an individual message and how that message should be handled.
    public var to: String?
    
    public var from: String?
    
    public var cc: String?
    
    public var bcc: String?
    
    public var replyTo: String?
    
    /// The global, or “message level”, subject of your email. This may be overridden by personalizations[x].subject.
    public var subject: String?
    
    /// An array in which you may specify the content of your email.
    public var text: String?
    public var html: String?
    
    /// An array of objects in which you can specify any attachments you want to include.
    public var attachments: [EmailAttachment]?
    
    public typealias RecipientVariables = [String: [String: String]]
    
    public var recipientVariables: String?
    public var deliveryTime: String?
    public var testmode: String?
    
    public init(from: String? = nil, replyTo: EmailAddress? = nil,
                cc: [EmailAddress]? = nil,
                bcc: [EmailAddress]? = nil,
                to: [EmailAddress]? = nil,
                text: String? = nil,
                html: String? = nil,
                subject: String? = nil,
                attachments: [EmailAttachment]? = nil,
                recipientVariables: RecipientVariables? = nil, deliveryTime: Date? = nil, testmode: Bool? = false) {
        self.from = from
        self.replyTo = replyTo?.email
        self.to = to?.stringArray.joined(separator: ",")
        self.cc = cc?.stringArray.joined(separator: ",")
        self.bcc = bcc?.stringArray.joined(separator: ",")
        self.text = text
        self.html = html
        self.subject = subject
        self.attachments = attachments
        if let testmode = testmode {
            self.testmode = testmode ? "true" : "false"
        }
        if let deliveryTime = deliveryTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
            self.deliveryTime = formatter.string(from: deliveryTime)
        }
        
        if let data = try? JSONEncoder().encode(recipientVariables) {
            self.recipientVariables = String(data: data, encoding: .utf8)!
//            do {
//                let textTemplate = try Template(string: text ?? "")
//                let htmlTemplate = try Template(string: html ?? "")
//                // Let template format dates with `{{format(...)}}`
//                let dateFormatter = MyDateFormatter()
//                dateFormatter.dateStyle = .medium
//                textTemplate.register(dateFormatter, forKey: "format")
//                htmlTemplate.register(dateFormatter, forKey: "format")
//                if let data2 = mustacheData?.data(using: .utf8) {
//                    if let jsonRaw = try? JSONSerialization.jsonObject(with: data2) {
//                        if let json = jsonRaw as? [String : Any] {
//                            self.text = try textTemplate.render(json)
//                            self.html = try htmlTemplate.render(json)
//                        }
//                    }
//                }
//                
//                
//            } catch {
//                print(error.localizedDescription)
//            }
        }
        
    }
    
    public enum CodingKeys: String, CodingKey {
        case from
        case replyTo = "h:Reply-To"
        case to
        case cc
        case bcc
        case text
        case html
        case subject
        case attachments
        case recipientVariables = "recipient-variables"
        case deliveryTime = "o:deliverytime"
        case testmode = "o:testmode"
    }
}

//public struct RecipientVariables: Content {
//
//    public var content: [String: [String: String]]
//
//
//}

class MyDateFormatter: DateFormatter {
    
    override func string(for obj: Any?) -> String? {
        if let dateString = obj as? String {
            return dateString
        }
        return ""
    }
    
}

public struct MailgunEmailPlus<Element: Codable>: MailgunEmailType {
    public var to: String?
    
    public var from: String?
    
    public var cc: String?
    
    public var bcc: String?
    
    public var replyTo: String?
    
    /// The global, or “message level”, subject of your email. This may be overridden by personalizations[x].subject.
    public var subject: String?
    
    /// An array in which you may specify the content of your email.
    public var text: String?
    public var html: String?
    
    /// An array of objects in which you can specify any attachments you want to include.
    public var attachments: [EmailAttachment]?
    //var data: Element
    public var recipientVariables: String?
    public var deliveryTime: String?
    public var testmode: String?
    
    public static var defaultContentType: MediaType {
        get {
            return MediaType.formData
        }
    }
    
    public init(from: String? = nil, replyTo: EmailAddress? = nil,
                cc: [EmailAddress]? = nil,
                bcc: [EmailAddress]? = nil,
                to: [EmailAddress]? = nil,
                text: String? = nil,
                html: String? = nil,
                subject: String? = nil,
                attachments: [EmailAttachment]? = nil,
                deliveryTime: Date? = nil, data: Element, testmode: Bool? = false) {
        self.from = from
        self.replyTo = replyTo?.email
        self.to = to?.stringArray.joined(separator: ",")
        self.cc = cc?.stringArray.joined(separator: ",")
        self.bcc = bcc?.stringArray.joined(separator: ",")
        self.text = text
        self.html = html
        self.subject = subject
        self.attachments = attachments
        if let testmode = testmode {
            self.testmode = testmode ? "true" : "false"
        }
        if let deliveryTime = deliveryTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
            self.deliveryTime = formatter.string(from: deliveryTime)
        }
//        let personalizations = [to!.first!.rawEmail : data]
//        if let data = try? JSONEncoder().encode(personalizations) {
//            //self.recipientVariables = String(data: data, encoding: .utf8)!
//            
//        }

        
    }
    
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
        case deliveryTime = "o:deliverytime"
        case testmode = "o:testmode"
    }
}

