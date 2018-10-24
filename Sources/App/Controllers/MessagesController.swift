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
    
    func boot(router: Router) throws {
        let route = router.grouped(BespinApi.path, Token.parameter, MessagesController.path)
        let protectedRoutes = route.grouped(JWTMiddleWareProvider())
        protectedRoutes.post(Message.self, use: createHandler)
        
    }
    
    func createHandler(_ req: Request, entity: Message) throws -> EventLoopFuture<MessageResponse> {
        if let data = req.http.body.data {
            if let jsonRaw = try? JSONSerialization.jsonObject(with: data),
                let json = jsonRaw as? [String : Any] {
                print(json)
            }
        }
        //let kid = req.parameters.rawValues(for: Token.self).first
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
                        let mailgunEmail = MailgunEmail(from: entity.from?.email, replyTo: entity.replyTo, cc: entity.cc, bcc: entity.bcc, to: entity.to, text: template!.text, html: template!.html, subject: entity.subject ?? template!.subject, attachments: entity.attachments, recipientVariables: entity.recipientVariables, mustacheData: entity.mustacheData)
                        
                        return try mailgun.send(apiKey: token.token, domain: user.domain, mailgunEmail, on: req)
                    })
                } else {
                    let mailgun = try req.make(MailgunClient.self)
                    let mailgunEmail = MailgunEmail(from: entity.from?.email, replyTo: entity.replyTo, cc: entity.cc, bcc: entity.bcc, to: entity.to, text: entity.text, html: entity.html, subject: entity.subject, attachments: entity.attachments, recipientVariables: entity.recipientVariables, mustacheData: entity.mustacheData)
                    
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
    
    public typealias RecipientVariables = [String: [String: String]]
    //public typealias MustacheHash = [String: String]
    public typealias MustacheHash = String
    
    public var recipientVariables: RecipientVariables?
    public var template: String?
    //public var mustacheData: MustacheHash?
    public var mustacheData: MustacheHash?
    
    public init(from: EmailAddress? = nil, replyTo: EmailAddress? = nil,
                cc: [EmailAddress]? = nil,
                bcc: [EmailAddress]? = nil,
                to: [EmailAddress]? = nil,
                text: String? = nil,
                html: String? = nil,
                subject: String? = nil,
                attachments: [EmailAttachment]? = nil,
                recipientVariables: RecipientVariables? = nil, template: String? = nil, mustacheData: MustacheHash? = nil) {
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
        self.mustacheData = mustacheData
        //self.mustacheData2 = mustacheData2
//        if let data = try? JSONEncoder().encode(recipientVariables) {
//            self.recipientVariables = String(data: data, encoding: .utf8)!
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
        case attachments
        case recipientVariables = "recipient-variables"
        case template
        case mustacheData
        //case mustacheData2
    }
}
