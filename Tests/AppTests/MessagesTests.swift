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
    
    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .Bespin).wait()
        //headers = app.defaultHeaders()
        
        user = try! User.create(domain: "sandbox1ae25b0dd717479699708a4953bcec8a.mailgun.org", on: conn)
        let token = Token(token: "<apikey>", userID: user.id!)
        try! token.save(on: conn).wait()
        uri = "/api/\(token.id!.uuidString)/messages/"

        // create payload
        let webToken = WebToken(name: "name", key: token.id?.uuidString ?? "uuid", domain: "sandbox1ae25b0dd717479699708a4953bcec8a.mailgun.org")
        
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
            from: EmailAddress(email: "mailgun@sandbox1ae25b0dd717479699708a4953bcec8a.mailgun.org"),
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
            from: EmailAddress(email: "mailgun@sandbox1ae25b0dd717479699708a4953bcec8a.mailgun.org"),
            to: [EmailAddress(email: testEmail)],
            text: "This is a newsletter from the api",
            html: "<h1>This is a newsletter from the api</h1>",
            subject: "Newsletter for %recipient.name% from the api",
            recipientVariables: variables
        )
        
        let user = try! User.create(username: "testAPICanSendMessageWithVariablesFailsBadToken", domain: "sandbox1ae25b0dd717479699708a4953bcec8a.mailgun.org", on: conn)
        let token = Token(token: "badtoken", userID: user.id!)
        try! token.save(on: conn).wait()
        
        let failUri = "/api/\(token.id!.uuidString)/messages/"
        
        // create payload
        let webToken = WebToken(name: "name", key: token.id?.uuidString ?? "uuid", domain: "sandbox1ae25b0dd717479699708a4953bcec8a.mailgun.org")
        
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
            from: EmailAddress(email: "mailgun@sandbox1ae25b0dd717479699708a4953bcec8a.mailgun.org"),
            to: [EmailAddress(email: testEmail)],
            text: "This is a newsletter from the api",
            html: "<h1>This is a newsletter from the api</h1>",
            subject: "Newsletter for %recipient.name% from the api",
            recipientVariables: variables
        )
        
        let user = try! User.create(username: "testAPICanSendMessageWithVariablesFailsBadDomain", domain: "sandbox1ae25b0dd717479699708a4953bcec8a.mailgun.org", on: conn)
        let token = Token(token: "<apikey>", userID: user.id!)
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
            from: EmailAddress(email: "mailgun@sandbox1ae25b0dd717479699708a4953bcec8a.mailgun.org"),
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
            from: EmailAddress(email: "mailgun@sandbox1ae25b0dd717479699708a4953bcec8a.mailgun.org"),
            to: [EmailAddress(email: testEmail)],
            subject: "Newsletter for %recipient.name% from the api",
            recipientVariables: variables,
            template: template.id?.uuidString,
            mustacheData: dataString
        )
        //        let response = try app.sendRequest(to: uri, method: HTTPMethod.POST, headers: headers, body: message)
        //        let messageResponse = try response.content.decode(MessageResponse.self).wait()
        //        print(messageResponse)
        let response = try app.getResponse(to: uri, method: .POST, headers: headers, data: message, decodeTo: MessageResponse.self)
        print(response.message)
    }
    
}
