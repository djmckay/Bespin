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
    //var attachments: [EmailAttachment]? { get set }
    var attachment:  [File]? { get set }
//    var attachment1: EmailAttachment? { get set }
//    var attachment2: EmailAttachment? { get set }
    var recipientVariables: String? { get set }
    var deliveryTime: String? { get set }
    var testmode: Bool? { get set }
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
    //public var attachments: [EmailAttachment]?
//    public var attachment1: EmailAttachment?
//    public var attachment2: EmailAttachment?
    public var attachment: [File]?
    public typealias RecipientVariables = [String: [String: String]]
    
    public var recipientVariables: String?
    public var deliveryTime: String?
    public var testmode: Bool?
    
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
        if let emailAttachments = attachments {
            self.attachment = []
            for emailAttachment in emailAttachments {
                let anAttachment = File(data: emailAttachment.data, filename: emailAttachment.filename)
                self.attachment?.append(anAttachment)
            }
        }
        //self.attachments = attachments
//        self.attachment1 = attachments?.first
//        if attachments?.count == 2 {
//            self.attachment2 = attachments![1]
//        }
        self.testmode = testmode
        if let deliveryTime = deliveryTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
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
        case attachment
        //case attachments = "attachment"
//        case attachment1 = "attachment[0]"
//        case attachment2 = "attachment[1]"
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
    //public var attachments: [EmailAttachment]?
    public var attachment: [File]?
//    public var attachment1: EmailAttachment?
//    public var attachment2: EmailAttachment?
    //var data: Element
    public var recipientVariables: String?
    public var deliveryTime: String?
    public var testmode: Bool?
    
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
        //self.attachments = attachments
        if let emailAttachments = attachments {
            self.attachment = []
            for emailAttachment in emailAttachments {
                let anAttachment = File(data: emailAttachment.data, filename: emailAttachment.filename)
                self.attachment?.append(anAttachment)
            }
        }
        self.testmode = testmode
//        self.attachment1 = attachments?.first
//        if attachments?.count == 2 {
//            self.attachment2 = attachments![1]
//        }
        if let deliveryTime = deliveryTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
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
        //case attachments = "attachment"
        case attachment
//        case attachment1 = "attachment[0]"
//        case attachment2 = "attachment[1]"
        case recipientVariables = "recipient-variables"
        case deliveryTime = "o:deliverytime"
        case testmode = "o:testmode"
    }
}


public struct MailgunAttachment: Content {
    

    
    /// The Base64 encoded content of the attachment.
    public var content: String?

    /// The mime type of the content you are attaching. For example, “text/plain” or “text/html”.
    public var type: String?

    /// The filename of the attachment.
    public var filename: String?

    /// The content-disposition of the attachment specifying how you would like the attachment to be displayed.
    public var disposition: String?

    /// The content id for the attachment. This is used when the disposition is set to “inline” and the attachment is an image, allowing the file to be displayed within the body of your email.
    public var contentId: String?

    public init(content: String? = nil,
                type: String? = nil,
                filename: String? = nil,
                disposition: String? = nil,
                contentId: String? = nil) {
        self.content = content
        self.type = type
        self.filename = filename
        self.disposition = disposition
        self.contentId = contentId
    }

    public enum CodingKeys: String, CodingKey {
        case content
        case type
        case filename
        case disposition
        case contentId = "content_id"
    }
}
