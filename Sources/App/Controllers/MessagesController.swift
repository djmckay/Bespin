//
//  MessagesController.swift
//  App
//
//  Created by DJ McKay on 10/23/18.
//

import Vapor
import JWT

struct MessagesController: RouteCollection {
    
    typealias T = User
    static var path = "messages"
    static var invites = "invites"
    static var batchInvites = "batchInvites"
    static var eventRegistration = "eventRegistration"
    func boot(router: Router) throws {
        let route = router.grouped(BespinApi.path, Token.parameter, MessagesController.path)
        let protectedRoutes = route.grouped(JWTMiddleWareProvider())
        protectedRoutes.post(Message.self, use: createHandler)
        protectedRoutes.post(EventRegistration.self, at: MessagesController.eventRegistration, use: sendEventRegistration)
        protectedRoutes.post(Invite.self, at: MessagesController.invites, use: sendInvite)
        
        protectedRoutes.post([Invite].self, at: MessagesController.batchInvites, use: sendInvitesAsBatch)
    }
    
    func sendEventRegistration(_ req: Request, entity: EventRegistration) throws -> EventLoopFuture<MessageResponse> {
        return try sendMessage("register", "registerText", req, entity)
    }
    
    func sendInvitesAsBatch(_ req: Request, entity: [Invite]) throws -> EventLoopFuture<[MessageResponse]> {
        return try req.parameters.next(Token.self).flatMap({ (token) -> EventLoopFuture<[Response]> in
            return token.user.get(on: req).flatMap({ (user) -> EventLoopFuture<[Response]> in
        var sendResults: [Future<Response>] = []
        for invite in entity {
            let response = try self.sendMessageUsingMailgun(user: user, token: token, leafHtml: "invite", leafText: "inviteText", req: req, entity: invite)
            sendResults.append(response)
        }
                return sendResults.flatten(on: req)

            })
        }).map({ (responses) -> ([MessageResponse]) in
            var sendResults: [MessageResponse] = []
            for response in responses {
                if let data = response.http.body.data, let messageResponse = (try? JSONDecoder().decode(MessageResponse.self, from: data)) {
                    sendResults.append(messageResponse)
                } else {
                    throw MailgunClient.Error.encodingProblem
                }
            }
            return sendResults
            //return MessageResponse(message: "Unable", id: "id")
        })
        
    }
    
    func sendInvite(_ req: Request, entity: Invite) throws -> EventLoopFuture<MessageResponse> {
        return try sendMessage("invite", "inviteText", req, entity)
    }
    
    fileprivate func sendMessage<E>(_ leafHtml: String, _ leafText: String,_ req: Request, _ entity: E) throws -> EventLoopFuture<MessageResponse> where E: MessageLeaf {
        return try req.parameters.next(Token.self).flatMap({ (token) -> EventLoopFuture<Response> in
            return token.user.get(on: req).flatMap({ (user) -> EventLoopFuture<Response> in
                return try self.sendMessageUsingMailgun(user: user, token: token, leafHtml: leafHtml, leafText: leafText, req: req, entity: entity)
                //                        return try req.view().render("register", entity.data).flatMap({ (view) -> EventLoopFuture<Response> in
                //                            let html = String(data: view.data, encoding: .utf8) ?? ""
                //                            let mailgunEmail = MailgunEmail(from: entity.from, replyTo: EmailAddress(email: entity.replyTo ?? ""), cc: ccAddresses, bcc: bccAddresses, to: toAddresses, text: "", html: html, subject: entity.subject, attachments: entity.attachments)
                //
                //                            return try mailgun.send(apiKey: token.token, domain: user.domain, mailgunEmail, on: req)
                //                        })
                
                
                //})
                
            })
            
        }).map({ (response) -> (MessageResponse) in
            if let data = response.http.body.data, let messageResponse = (try? JSONDecoder().decode(MessageResponse.self, from: data)) {
                return messageResponse
            } else {
                throw MailgunClient.Error.encodingProblem
            }
            
            //return MessageResponse(message: "Unable", id: "id")
        })
    }
    
    fileprivate func sendMessageUsingMailgun<E>(user: User, token: Token, leafHtml: String, leafText: String, req: Request, entity: E)  throws -> EventLoopFuture<Response>  where E: MessageLeaf {
        let bearer = req.http.headers.bearerAuthorization!
        let jwt = try JWT<WebToken>(from: bearer.token, verifiedUsing: .hs256(key: token.token))
        guard jwt.payload.domain == user.domain else {
            throw MailgunClient.Error.authenticationFailed
        }
        
        //let id = UUID(uuidString: entity.leaf)!
        //return EmailTemplate.find(id, on: req).flatMap({ (template) -> EventLoopFuture<Response> in
        let mailgun = try req.make(MailgunClient.self)
//        let toAddresses = (entity.personalizations?.to ?? entity.to)?.map { (email) -> EmailAddress in
//            return EmailAddress(email: email)
//        }
//        let ccAddresses = (entity.personalizations?.cc ?? entity.cc)?.map { (email) -> EmailAddress in
//            return EmailAddress(email: email)
//        }
//        let bccAddresses = (entity.personalizations?.bcc ?? entity.bcc)?.map { (email) -> EmailAddress in
//            return EmailAddress(email: email)
//        }
        let ccAddresses = entity.cc?.map({ (email) -> EmailAddress in
            return EmailAddress(email: email)
        })
        let bccAddresses = entity.bcc?.map({ (email) -> EmailAddress in
            return EmailAddress(email: email)
        })
        let toAddresses = entity.to?.map({ (email) -> EmailAddress in
            return EmailAddress(email: email)
        })
        if let template = entity.leaf {
            let id = UUID(uuidString: template)!
            return EmailTemplate.find(id, on: req).flatMap({ (template) -> EventLoopFuture<Response> in
                let render = try req.make(TemplateRenderer.self)
                return flatMap(try render.renderString(template!.html, context: entity.data), try render.renderString(template!.text, context: entity.data), try render.renderString(entity.subject ?? template!.subject ?? "", context: entity.data), { (htmlView, textView, subjectView) -> (EventLoopFuture<Response>) in
                    let html = String(data: htmlView.data, encoding: .utf8) ?? ""
                    let text = String(data: textView.data, encoding: .utf8) ?? ""
                    let subject = String(data: subjectView.data, encoding: .utf8) ?? ""
                    if let templateAttachments = template?.attachments {
                        var storageResults: [Future<EmailTemplateAttachment>] = []
                        return try templateAttachments.query(on: req).all().flatMap({ (attachments) -> EventLoopFuture<Response> in
                            let messageAttachments = try attachments.compactMap({ (attachment) -> EmailAttachment in
                                
                                if let path = attachment.path {
                                    
                                    let storageData = try Storage.get(path: path, on: req).flatMap({ (bytes) -> EventLoopFuture<String?> in
                                        let data = Data(bytes: bytes, count: bytes.count)
                                        
                                        return req.future(data.base64EncodedString())
                                    }).flatMap({ (string) -> EventLoopFuture<EmailTemplateAttachment> in
                                        if let string = string {
                                            attachment.data = string
                                        }
                                        return req.future(attachment)
                                    })
                                    storageResults.append(storageData)
                                }
                                
                                return EmailAttachment(data: attachment.data!, filename: attachment.filename)
                            })
                            
                            let mailgunEmail = MailgunEmailPlus(from: entity.from, replyTo: EmailAddress(email: entity.replyTo ?? ""), cc: ccAddresses, bcc: bccAddresses, to: toAddresses, text: text, html: html, subject: subject, attachments: entity.attachments ?? messageAttachments, deliveryTime: entity.deliveryTime, data: entity.data, testmode: entity.testmode)
                            
                            return try mailgun.send(apiKey: token.token, domain: user.domain, mailgunEmail, on: req)
                        })
                    } else {
                        let mailgunEmail = MailgunEmailPlus(from: entity.from, replyTo: EmailAddress(email: entity.replyTo ?? ""), cc: ccAddresses, bcc: bccAddresses, to: toAddresses, text: text, html: html, subject: subject, attachments: entity.attachments, deliveryTime: entity.deliveryTime, data: entity.data, testmode: entity.testmode)
                        
                        return try mailgun.send(apiKey: token.token, domain: user.domain, mailgunEmail, on: req)
                    }
                    
                    
                })
            })
        } else {
            let render = try req.make(TemplateRenderer.self)
            return flatMap(try req.view().render(leafHtml, entity.data), try req.view().render(leafText, entity.data), try render.renderString(entity.subject ?? "", context: entity.data), { (htmlView, textView, subjectView) -> (EventLoopFuture<Response>) in
                let html = String(data: htmlView.data, encoding: .utf8) ?? ""
                let text = String(data: textView.data, encoding: .utf8) ?? ""
                let subject = String(data: subjectView.data, encoding: .utf8) ?? ""
                let mailgunEmail = MailgunEmailPlus(from: entity.from, replyTo: EmailAddress(email: entity.replyTo ?? ""), cc: ccAddresses, bcc: bccAddresses, to: toAddresses, text: text, html: html, subject: subject, attachments: entity.attachments, deliveryTime: entity.deliveryTime, data: entity.data, testmode: entity.testmode)
                
                return try mailgun.send(apiKey: token.token, domain: user.domain, mailgunEmail, on: req)
                
            })
        }
    }
    
    func createHandler(_ req: Request, entity: Message) throws -> EventLoopFuture<MessageResponse> {
        return try req.parameters.next(Token.self).flatMap({ (token) -> EventLoopFuture<Response> in
            return token.user.get(on: req).flatMap({ (user) -> EventLoopFuture<Response> in
                let bearer = req.http.headers.bearerAuthorization!
                let jwt = try JWT<WebToken>(from: bearer.token, verifiedUsing: .hs256(key: token.token))
                guard jwt.payload.domain == user.domain else {
                    throw MailgunClient.Error.authenticationFailed
                }
                if let template = entity.template {
                    let id = UUID(uuidString: template)!
                    return EmailTemplate.find(id, on: req).flatMap({ (template) -> EventLoopFuture<Response> in
                        let mailgun = try req.make(MailgunClient.self)
                        guard let template = template else { throw Abort(.forbidden, reason: "Invalid Template") }
                        var templateReplyTo: EmailAddress?
                        if let templateReplyToString = template.replyTo, !templateReplyToString.isEmpty {
                            templateReplyTo = EmailAddress(email: templateReplyToString)
                        }
                        var templateCc: [EmailAddress]?
                        if let templateCcString = template.cc {
                            let inputs = templateCcString.split(separator: ",")
                            if !inputs.isEmpty {
                                templateCc = []
                                for input in inputs {
                                    templateCc?.append(EmailAddress(email: String(input)))
                                }
                            }
                        }
                        var templateBcc: [EmailAddress]?
                        if let templateBccString = template.bcc {
                            let inputs = templateBccString.split(separator: ",")
                            if !inputs.isEmpty {
                                templateBcc = []
                                for input in inputs {
                                    templateBcc?.append(EmailAddress(email: String(input)))
                                }
                            }
                            
                        }
                        return try template.attachments.query(on: req).all().flatMap({ (attachments) -> EventLoopFuture<Response> in
                            var storageResults: [Future<EmailTemplateAttachment>] = []
                            try attachments.forEach({ (attachment) in
                                if let path = attachment.path {
                                    
                                    let storageData = try Storage.get(path: path, on: req).flatMap({ (bytes) -> EventLoopFuture<String?> in
                                        let data = Data(bytes: bytes, count: bytes.count)
                                        
                                        return req.future(data.base64EncodedString())
                                    }).flatMap({ (string) -> EventLoopFuture<EmailTemplateAttachment> in
                                        if let string = string {
                                            attachment.data = string
                                        }
                                        return req.future(attachment)
                                    })
                                    storageResults.append(storageData)
                                }
                            })
                            return storageResults.flatten(on: req).flatMap({ (attachments) -> EventLoopFuture<Response> in
                                let messageAttachments = attachments.compactMap({ (attachment) -> EmailAttachment in
                                    return EmailAttachment(data: attachment.data!, filename: attachment.filename)
                                })
                                let mailgunEmail = MailgunEmail(from: entity.from?.email ?? template.from, replyTo: entity.replyTo ?? templateReplyTo, cc: entity.cc ?? templateCc, bcc: entity.bcc ?? templateBcc, to: entity.to, text: template.text, html: template.html, subject: entity.subject ?? template.subject, attachments: entity.attachments ?? messageAttachments, recipientVariables: entity.recipientVariables, deliveryTime: entity.deliveryTime, testmode: entity.testmode)
                                
                                return try mailgun.send(apiKey: token.token, domain: user.domain, mailgunEmail, on: req)
                            })
                           
                        })
                        
                        
                        
                    })
                } else {
                    let mailgun = try req.make(MailgunClient.self)
                    let mailgunEmail = MailgunEmail(from: entity.from?.email, replyTo: entity.replyTo, cc: entity.cc, bcc: entity.bcc, to: entity.to, text: entity.text, html: entity.html, subject: entity.subject, attachments: entity.attachments, recipientVariables: entity.recipientVariables, deliveryTime: entity.deliveryTime, testmode: entity.testmode)
                    
                    return try mailgun.send(apiKey: token.token, domain: user.domain, mailgunEmail, on: req)
                }
            })
            
        }).map({ (response) -> (MessageResponse) in
            if let data = response.http.body.data, let messageResponse = (try? JSONDecoder().decode(MessageResponse.self, from: data)) {
                return messageResponse
            } else {
                throw MailgunClient.Error.encodingProblem
            }
            
            //return MessageResponse(message: "Unable", id: "id")
        })
        
    }
}

public struct MessageResponse: Content {
    /// messsage
    public let message: String
    public let id: String
}

public struct Message: Content {
    public static let defaultContentType: MediaType = .urlEncodedForm
    /// An array of messages and their metadata. Each object within personalizations can be thought of as an envelope - it defines who should receive an individual message and how that message should be handled.
    public var to: [EmailAddress]?
    
    public var from: EmailAddress?
    
    public var cc: [EmailAddress]?
    
    public var bcc: [EmailAddress]?
    
    public var replyTo: EmailAddress?
    
    /// The global, or “message level”, subject of your email. This may be overridden by personalizations[x].subject.
    public var subject: String?
    
    /// An array in which you may specify the content of your email.
    public var text: String?
    public var html: String?
    
    /// An array of objects in which you can specify any attachments you want to include.
    public var attachments: [EmailAttachment]?
    public var deliveryTime: Date?
    
    public typealias RecipientVariables = [String: [String: String]]
    
    public var recipientVariables: RecipientVariables?
    public var template: String?
    public var testmode: Bool?
    
    public init(from: EmailAddress? = nil, replyTo: EmailAddress? = nil,
                cc: [EmailAddress]? = nil,
                bcc: [EmailAddress]? = nil,
                to: [EmailAddress]? = nil,
                text: String? = nil,
                html: String? = nil,
                subject: String? = nil,
                attachments: [EmailAttachment]? = nil,
                recipientVariables: RecipientVariables? = nil, template: String? = nil, testmode: Bool? = false) {
        self.from = from
        self.replyTo = replyTo
        self.to = to
        self.cc = cc
        self.bcc = bcc
        self.text = text
        self.html = html
        self.subject = subject
        self.attachments = attachments
        self.recipientVariables = recipientVariables
        self.template = template
        self.testmode = testmode
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
        case template
        case deliveryTime
        case testmode
    }
}

protocol MessageLeaf: Content {
    var leaf: String? { get set }
    associatedtype D where D: Content
    var data: D { get set }
    var to: [String]? { get set }
    var cc: [String]? { get set }
    var bcc: [String]? { get set }
    var attachments: [EmailAttachment]? { get set }
    var subject: String? { get set }
    var from: String { get set }
    var replyTo: String? { get set }
    var deliveryTime: Date? { get set }
    var recipientVariables: [String: [String: String]]? { get set }
    var testmode: Bool? { get set }
}

protocol Personalizations: Content {
    associatedtype D where D: Content
    var data: D { get set }
    var to: [String]? { get set }
    var cc: [String]? { get set }
    var bcc: [String]? { get set }
    var subject: String? { get set }
}
public struct EventRegistration: MessageLeaf {
    var leaf: String?
    var data: EventEmailTemplateData
    var to: [String]?
    var cc: [String]?
    var bcc: [String]?
    var attachments: [EmailAttachment]?
    var subject: String?
    var from: String
    var replyTo: String?
    var deliveryTime: Date?
    var testmode: Bool?
    var recipientVariables: [String: [String: String]]?
}

public struct Event: Content {
    var name: String
    var year: String
    var date: Date
    var longName: String
    var sponsorCompanyName: String
    var title: String
    var location: String
    var registrationUpdateLink: String
    var logoBase64: String?
}

public struct  Sender: Content {
    var signature: String
    var email: String
    var name: String
    var tagLine: String
}

public struct Attendee: Content {
    var firstName: String
    var lastName: String
    var addressLine1: String
    var addressLine2: String?
    var addressCity: String
    var addressState: String
    var addressZip: String
    var addressCountry: String
    var email: String
    var phone: String
}

struct EventEmailTemplateData: Content {
    var confirmation: String
    var sender: Sender
    var event: Event
    var attendee: Attendee
    var footer: String
    var optionals: [String]
    var additionals: [String]
    var footerLinks: [String]
    var now: Date
}


public struct Invite: MessageLeaf {
    var leaf: String?
    var data: InviteTemplateData
    var to: [String]?
    var cc: [String]?
    var bcc: [String]?
    var attachments: [EmailAttachment]?

    var subject: String?
    var from: String
    var replyTo: String?
    var deliveryTime: Date?
    var testmode: Bool?
    var recipientVariables: [String: [String: String]]?
}


struct InviteTemplateData: Content {
    var sender: Sender
    var vendor: EventVendor
    var event: Event
    var footer: String
    var optionals: [String]
    var additionals: [String]
    var footerLinks: [String]
}

struct EventVendor: Content {
    var name: String
}
