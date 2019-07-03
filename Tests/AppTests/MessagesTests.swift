//
//  MessagesTests.swift
//  AppTests
//
//  Created by DJ McKay on 10/23/18.
//

@testable import App
import Vapor
import XCTest
import FluentMySQL
import JWT

final class MessagesTests: XCTestCase {
    
    var uri: String = "/api/uuid/messages/"
    var app: Application!
    var conn: MySQLConnection!
    var headers: HTTPHeaders!
    let testEmail = "testing@ibtuf.com"
    var user: User!
    var apiKey: String!
    let domain = "sandbox1ae25b0dd717479699708a4953bcec8a.mailgun.org"
    let senderEmail = "mailgun@"
    
    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .Bespin).wait()
        //headers = app.defaultHeaders()
        let testBundle = Bundle(for: AppTests.self)
        apiKey = testBundle.infoDictionary?["MG_API_AUTHORIZE_KEY"] as? String ?? "<apikey>"
        user = try! User.create(domain: domain, on: conn)
        let token = Token(token: apiKey, userID: user.id!)
        try! token.save(on: conn).wait()
        uri = "/api/\(token.id!.uuidString)/messages/"

        // create payload
        let webToken = WebToken(name: "name", key: token.id?.uuidString ?? "uuid", domain: domain)
        
        // create JWT and sign
        let jwt = try! JWT(payload: webToken).sign(using: .hs256(key: token.token))
        headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer \(String(data: jwt, encoding: .utf8) ?? "")")
        headers.add(name: "Content-Type", value: "application/json")
        
    }
    
    override func tearDown() {
        conn.close()
    }
    
    
    
    func testAPICanSendMessageWithVariables() throws {
        let variables = [testEmail : ["name" : "dj"]]
        let message = Message(
            from: EmailAddress(email: senderEmail+domain),
            to: [EmailAddress(email: testEmail)],
            text: "This is a newsletter from the api",
            html: "<h1>This is a newsletter from the api</h1>",
            subject: "Newsletter for %recipient.name% from the api",
            recipientVariables: variables
        )
//        let response = try app.sendRequest(to: uri, method: HTTPMethod.POST, headers: headers, body: message)
//        let messageResponse = try response.content.decode(MessageResponse.self).wait()
//        print(messageResponse)
        let response = try app.getResponse(to: uri, method: .POST, headers: headers, data: message, decodeTo: MessageResponse.self)
        print(response.message)
    }
    
    func testAPICanSendMessageWithVariablesFailsBadToken() throws {
        let variables = [testEmail : ["name" : "dj"]]
        let message = Message(
            from: EmailAddress(email: senderEmail+domain),
            to: [EmailAddress(email: testEmail)],
            text: "This is a newsletter from the api",
            html: "<h1>This is a newsletter from the api</h1>",
            subject: "Newsletter for %recipient.name% from the api",
            recipientVariables: variables
        )
        
        let user = try! User.create(username: "testAPICanSendMessageWithVariablesFailsBadToken", domain: domain, on: conn)
        let token = Token(token: "badtoken", userID: user.id!)
        try! token.save(on: conn).wait()
        
        let failUri = "/api/\(token.id!.uuidString)/messages/"
        
        // create payload
        let webToken = WebToken(name: "name", key: token.id?.uuidString ?? "uuid", domain: domain)
        
        // create JWT and sign
        let jwt = try! JWT(payload: webToken).sign(using: .hs256(key: token.token))
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer \(String(data: jwt, encoding: .utf8) ?? "")")
        headers.add(name: "Content-Type", value: "application/json")
        
        do {
            let response = try app.sendRequest(to: failUri, method: HTTPMethod.POST, headers: headers, body: message)
            if response.http.status != HTTPStatus.internalServerError {
                XCTFail()
            }
            //let response = try app.getResponse(to: uri, headers: headers, data: message, decodeTo: EmptyContent.self)
        } catch (MailgunClient.Error.authenticationFailed) {
            
        } catch {
            XCTFail()
        }
    }
    
    func testAPICanSendMessageWithVariablesFailsBadDomain() throws {
        let variables = [testEmail : ["name" : "dj"]]
        let message = Message(
            from: EmailAddress(email: senderEmail+domain),
            to: [EmailAddress(email: testEmail)],
            text: "This is a newsletter from the api",
            html: "<h1>This is a newsletter from the api</h1>",
            subject: "Newsletter for %recipient.name% from the api",
            recipientVariables: variables
        )
        
        let user = try! User.create(username: "testAPICanSendMessageWithVariablesFailsBadDomain", domain: domain, on: conn)
        let token = Token(token: apiKey, userID: user.id!)
        try! token.save(on: conn).wait()
        
        let uri = "/api/\(token.id!.uuidString)/messages/"
        
        // create payload
        let webToken = WebToken(name: "name", key: token.id?.uuidString ?? "uuid", domain: "sandbox1ae25b0dd717479699708a4953bcec8a.mailgun.bad")
        
        // create JWT and sign
        let jwt = try! JWT(payload: webToken).sign(using: .hs256(key: token.token))
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer \(String(data: jwt, encoding: .utf8) ?? "")")
        headers.add(name: "Content-Type", value: "application/json")
        
        do {
            let response = try app.sendRequest(to: uri, method: HTTPMethod.POST, headers: headers, body: message)
            if response.http.status != HTTPStatus.internalServerError {
                XCTFail()
            }
        //let response = try app.getResponse(to: uri, headers: headers, data: message, decodeTo: EmptyContent.self)
        } catch (MailgunClient.Error.authenticationFailed) {
    
        } catch {
            XCTFail()
        }
        
        
        
    }
    
    func testAPICanSendMessageUsingTemplateWithVariables() throws {
        let variables = [testEmail : ["name" : "dj"]]
        let expectedName = "Template1"
        let expectedText = "Hello this is template text for %recipient.name%"
        let expectedHtml = "<b>Hello this is template html for %recipient.name%</b>"
        let template = try EmailTemplate.create(name: expectedName, text: expectedText, html: expectedHtml, user: user, on: conn)
        let message = Message(
            from: EmailAddress(email: senderEmail+domain),
            to: [EmailAddress(email: testEmail)],
            subject: "Newsletter for %recipient.name% from the api",
            recipientVariables: variables,
            template: template.id?.uuidString
        )
        //        let response = try app.sendRequest(to: uri, method: HTTPMethod.POST, headers: headers, body: message)
        //        let messageResponse = try response.content.decode(MessageResponse.self).wait()
        //        print(messageResponse)
        let response = try app.getResponse(to: uri, method: .POST, headers: headers, data: message, decodeTo: MessageResponse.self)
        print(response.message)
    }
    
    func testAPICanSendMessageUsingMustacheTemplateWithVariables() throws {
        let realDate = Date().addingTimeInterval(60*60*24*3)
        let date = Date()
        // The rendered data
        let data: [String: String] = [
            "name": "Mustache",
            "date": date.description,
            "realDate": realDate.description,
            "late": "true"
        ]
        
        let data2: [String: Codable] = [
            "name": "Mustache",
            "date": date.description,
            "realDate": realDate.description,
            "late": "true",
            "items": [["name": "one"], ["name": "two"]]
        ]
        var dataString: String?
        if let data = try? JSONSerialization.data(withJSONObject: data2, options: []) {
            dataString = String(data: data, encoding: .utf8)!
        }
//        if let data = try? JSONEncoder().encode(data) {
//            dataString = String(data: data, encoding: .utf8)!
//        }
        let variables = [testEmail : data]
        let expectedName = "Template1"
        let expectedText = "Hello {{name}} {{format(date)}} {{format(realDate)}}.  There are {{items.count}} item(s): {{#items}} {{name}} {{/items}}"
        let expectedHtml = "Hello {{name}} {{format(date)}} {{format(realDate)}}.  There are {{items.count}} item(s): {{#items}} {{name}} {{/items}}"
        let template = try EmailTemplate.create(name: expectedName, text: expectedText, html: expectedHtml, user: user, on: conn)
        let message = Message(
            from: EmailAddress(email: senderEmail+domain),
            to: [EmailAddress(email: testEmail)],
            subject: "Newsletter for %recipient.name% from the api",
            recipientVariables: variables,
            template: template.id?.uuidString
        )
        //        let response = try app.sendRequest(to: uri, method: HTTPMethod.POST, headers: headers, body: message)
        //        let messageResponse = try response.content.decode(MessageResponse.self).wait()
        //        print(messageResponse)
        let response = try app.getResponse(to: uri, method: .POST, headers: headers, data: message, decodeTo: MessageResponse.self)
        print(response.message)
    }
    
    func testAPICanSendEventRegistrationMessageUsingLeafTemplate() throws {
        let sender = Sender(signature: "customer service signature", email: "customerservice@vztuf.com", name: "iAM Wireless", tagLine: "customer service tagline")
        let data = EventEmailTemplateData(confirmation: "abc", sender: sender, event: Event(name: "name", year: "2020", date: Date(), longName: "longName", sponsorCompanyName: "Sponsor", title: "A title", location: "The location", registrationUpdateLink: "reglink", logoBase64: nil), attendee: Attendee(firstName: "first", lastName: "last", addressLine1: "line1", addressLine2: nil, addressCity: "city", addressState: "state", addressZip: "zip", addressCountry: "US", email: "testing@ibtuf.com", phone: "123"), footer: "footer", optionals: ["one","two", "three"], additionals: [], footerLinks: ["", "", "String"], now: Date())
        
        let registration = EventRegistration(leaf: nil, data: data, to: ["testing@ibtuf.com"], cc: nil, bcc: nil, attachments: nil, subject: "test subject", from: senderEmail+domain, replyTo: nil, deliveryTime: nil, recipientVariables: nil)
        
        let response = try app.getResponse(to: uri+"eventRegistration/", method: .POST, headers: headers, data: registration, decodeTo: MessageResponse.self)
        print(response.message)
    }
    
    func testAPICanSendExhibitorInviteMessageUsingLeafTemplate() throws {
        let event = Event(name: "name", year: "2020", date: Date(), longName: "longName", sponsorCompanyName: "Sponsor", title: "A title", location: "The location", registrationUpdateLink: "reglink", logoBase64: nil)
        let vendor = EventVendor(name: "invitee")
        let sender = Sender(signature: "customer service signature", email: "customerservice@vztuf.com", name: "iAM Wireless", tagLine: "customer service tagline")
        let data = InviteTemplateData(sender: sender, vendor: vendor, event: event, footer: "footer", optionals: [], additionals: [], footerLinks: [])
        let invite = Invite(leaf: nil, data: data, to: ["testing@ibtuf.com"], cc: nil, bcc: nil, attachments: nil, subject: "Invite", from: senderEmail+domain, replyTo: nil, deliveryTime: nil, recipientVariables: nil)
        
        let response = try app.getResponse(to: uri+MessagesController.invites, method: .POST, headers: headers, data: invite, decodeTo: MessageResponse.self)
        print(response.message)
    }
    
    func testAPICanSendExhibitorInviteMessageUsingLeafTemplateMultiple() throws {
        let event = Event(name: "name", year: "2020", date: Date(), longName: "longName", sponsorCompanyName: "Sponsor", title: "A title", location: "The location", registrationUpdateLink: "reglink", logoBase64: nil)
        let vendor = EventVendor(name: "invitee")
        let sender = Sender(signature: "customer service signature", email: "customerservice@vztuf.com", name: "iAM Wireless", tagLine: "customer service tagline")
        let data = InviteTemplateData(sender: sender, vendor: vendor, event: event, footer: "footer", optionals: [], additionals: [], footerLinks: [])
        let invite = Invite(leaf: nil, data: data, to: ["testing@ibtuf.com"], cc: nil, bcc: nil, attachments: nil, subject: "\(vendor.name) Invite", from: senderEmail+domain, replyTo: nil, deliveryTime: nil, recipientVariables: nil)
        
        let vendor2 = EventVendor(name: "invitee two")
        let data2 = InviteTemplateData(sender: sender, vendor: vendor2, event: event, footer: "footer", optionals: [], additionals: [], footerLinks: [])
        let invite2 = Invite(leaf: nil, data: data2, to: ["dj.leon.mckay@gmail.com"], cc: nil, bcc: nil, attachments: nil, subject: "\(vendor2.name) Invite", from: senderEmail+domain, replyTo: nil, deliveryTime: Date().addingTimeInterval(60*30), recipientVariables: nil)
        let responses = try app.getResponse(to: uri+MessagesController.batchInvites, method: .POST, headers: headers, data: [invite, invite2], decodeTo: [MessageResponse].self)
        for response in responses {
            print(response.message)
            print(response.id)
        }
        
    }
    
    func testAPICanSendExhibitorInviteMessageUsingSavedLeafTemplateMultiple() throws {
        let leafPath = "invite.leaf"
        let workDir = try app.make(DirectoryConfig.self).workDir
        let absolutePath = leafPath.hasPrefix("/") ? leafPath : workDir + "Resources/Views/" + leafPath
        let leafData = FileManager.default.contents(atPath: absolutePath)!
        let leafHtml = String(data: leafData, encoding: .utf8)
        let template = try EmailTemplate.create(name: "InviteTest", text: "", html: leafHtml!, subject: "#(vendor.name)", user: user, on: conn)
        let leaf = template.id!.uuidString
        let event = Event(name: "name", year: "2020", date: Date(), longName: "longName", sponsorCompanyName: "Sponsor", title: "A title", location: "The location", registrationUpdateLink: "reglink", logoBase64: nil)
        let vendor = EventVendor(name: "invitee")
        let sender = Sender(signature: "customer service signature", email: "customerservice@vztuf.com", name: "iAM Wireless", tagLine: "customer service tagline")
        let data = InviteTemplateData(sender: sender, vendor: vendor, event: event, footer: "footer", optionals: [], additionals: [], footerLinks: [])
        let invite = Invite(leaf: leaf, data: data, to: ["testing@ibtuf.com"], cc: nil, bcc: nil, attachments: nil, subject: "#(vendor.name) Invite", from: senderEmail+domain, replyTo: nil, deliveryTime: nil, recipientVariables: nil)
        
        let vendor2 = EventVendor(name: "invitee two")
        let data2 = InviteTemplateData(sender: sender, vendor: vendor2, event: event, footer: "footer", optionals: [], additionals: [], footerLinks: [])
        
        let invite2 = Invite(leaf: leaf, data: data2, to: ["dj.leon.mckay@gmail.com"], cc: nil, bcc: nil, attachments: nil, subject: nil, from: senderEmail+domain, replyTo: nil, deliveryTime: Date().addingTimeInterval(60*1), recipientVariables: nil)
        let responses = try app.getResponse(to: uri+MessagesController.batchInvites, method: .POST, headers: headers, data: [invite, invite2], decodeTo: [MessageResponse].self)
        for response in responses {
            print(response.message)
            print(response.id)
        }
    }
    
//    func testAPICanSendExhibitorInviteMessageUsingSavedLeafTemplateMultipleAttachments() throws {
//        let leafPath = "invite.leaf"
//        let workDir = try app.make(DirectoryConfig.self).workDir
//        let absolutePath = leafPath.hasPrefix("/") ? leafPath : workDir + "Resources/Views/" + leafPath
//        let leafData = FileManager.default.contents(atPath: absolutePath)!
//        let leafHtml = String(data: leafData, encoding: .utf8)?.replacingOccurrences(of: "2019", with: "2020")
//        let template = try EmailTemplate.create(name: "InviteTest", text: "", html: leafHtml!, subject: "#(vendor.name)", user: user, on: conn)
//        let leaf = template.id!.uuidString
//        let content = "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"
//        let attachment = EmailAttachment(content: content, type: "image/png", filename: "testImage", disposition: nil, contentId: nil)
//        let event = Event(name: "name", year: "2020", date: Date(), longName: "longName", sponsorCompanyName: "Sponsor", title: "A title", location: "The location", registrationUpdateLink: "reglink", logoBase64: nil)
//        let vendor = EventVendor(name: "invitee")
//        let sender = Sender(signature: "customer service signature", email: "customerservice@vztuf.com", name: "iAM Wireless", tagLine: "customer service tagline")
//        let data = InviteTemplateData(sender: sender, vendor: vendor, event: event, footer: "footer", optionals: [], additionals: [], footerLinks: [])
//        let invite = Invite(leaf: leaf, data: data, to: ["testing@ibtuf.com"], cc: nil, bcc: nil, attachments: [attachment], subject: "#(vendor.name) Invite", from: senderEmail+domain, replyTo: nil, deliveryTime: nil, recipientVariables: nil)
//        
//        let vendor2 = EventVendor(name: "invitee two")
//        let data2 = InviteTemplateData(sender: sender, vendor: vendor2, event: event, footer: "footer", optionals: [], additionals: [], footerLinks: [])
//        let invite2 = Invite(leaf: leaf, data: data2, to: ["dj.leon.mckay@gmail.com"], cc: nil, bcc: nil, attachments: nil, subject: nil, from: senderEmail+domain, replyTo: nil, deliveryTime: Date().addingTimeInterval(60*1), recipientVariables: nil)
//        let responses = try app.getResponse(to: uri+MessagesController.batchInvites, method: .POST, headers: headers, data: [invite, invite2], decodeTo: [MessageResponse].self)
//        for response in responses {
//            print(response.message)
//            print(response.id)
//        }
//    }
    
}
