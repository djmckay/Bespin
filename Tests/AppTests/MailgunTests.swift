//
//  MailgunTests.swift
//  AppTests
//
//  Created by DJ McKay on 10/23/18.
//

@testable import App
import Vapor
import XCTest
import FluentMySQL

final class MailgunTests: XCTestCase {
    
    var app: Application!
    var conn: MySQLConnection!
    var headers: HTTPHeaders!
    
    var domain: String!
    var apiKey: String!
    
    let testEmail = "testing@ibtuf.com"
    
    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .Bespin).wait()
        headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: "application/json")
        domain = "sandbox1ae25b0dd717479699708a4953bcec8a.mailgun.org"
        let testBundle = Bundle(for: AppTests.self)
        apiKey = testBundle.infoDictionary?["MG_API_AUTHORIZE_KEY"] as? String ?? "<apikey>"
    }
    
    override func tearDown() {
        conn.close()
    }
    
    func testMailgunCanSendMessageAsArray() throws {
        let attachment = EmailAttachment(content: "content", type: "image/png", filename: "testImage", disposition: nil, contentId: nil)
        let message = MailgunEmail(
            from: "mailgun@sandbox1ae25b0dd717479699708a4953bcec8a.mailgun.org",
            to: [EmailAddress(email: "testing@ibtuf.com")],
            text: "This is a newsletter",
            html: "<h1>This is a newsletter</h1>",
            subject: "Newsletter"
            
        )
        
        let mailgun = try app.make(MailgunClient.self)
        do {
        try mailgun.send(apiKey: apiKey, domain: domain, [message], on: app).wait()
        } catch {
            print(error.localizedDescription)
            XCTFail()
        }
        
    }
    
    func testMailgunCanSendMessageAsArrayWithVariables() throws {
        let variables = [testEmail : ["name" : "dj"]]
        let message = MailgunEmail(
            from: "mailgun@sandbox1ae25b0dd717479699708a4953bcec8a.mailgun.org",
            to: [EmailAddress(email: testEmail)],
            text: "This is a newsletter",
            html: "<h1>This is a newsletter</h1>",
            subject: "Newsletter for %recipient.name%",
            recipientVariables: variables
        )
        
        let mailgun = try app.make(MailgunClient.self)
        do {
            try mailgun.send(apiKey: apiKey, domain: domain, [message], on: app).wait()
        } catch {
            print(error.localizedDescription)
            XCTFail()
        }
        
    }
    
    func testMailgunCanSendMessageAsArrayFails() throws {
        let message = MailgunEmail(
            from: "",
            to: [EmailAddress(email: testEmail)],
            text: "This is a newsletter",
            html: "<h1>This is a newsletter</h1>",
            subject: "Newsletter"
            
        )
        
        let mailgun = try app.make(MailgunClient.self)
        do {
            try mailgun.send(apiKey: apiKey, domain: domain, [message], on: app).wait()
            XCTFail()
        } catch {
            XCTAssertNotNil(error)
        }
        
    }
    
    func testMailgunCanSendMessage() throws {
        let message = MailgunEmail(
            from: "mailgun@sandbox1ae25b0dd717479699708a4953bcec8a.mailgun.org",
            to: [EmailAddress(email: "testing@ibtuf.com")],
            text: "This is a newsletter",
            html: "<h1>This is a newsletter</h1>",
            subject: "Newsletter"
            
        )
        
        let mailgun = try app.make(MailgunClient.self)
        do {
            let response = try mailgun.send(apiKey: apiKey, domain: domain, message, on: app).wait()
            XCTAssertTrue(response.http.status.code == HTTPStatus.ok.code)
        } catch {
            print(error.localizedDescription)
            XCTFail()
        }
        
    }
    
    func testMailgunCanSendMessageWithVariables() throws {
        let variables = [testEmail : ["name" : "dj"]]
        let message = MailgunEmail(
            from: "mailgun@sandbox1ae25b0dd717479699708a4953bcec8a.mailgun.org",
            to: [EmailAddress(email: testEmail)],
            text: "This is a newsletter",
            html: "<h1>This is a newsletter</h1>",
            subject: "Newsletter for %recipient.name%",
            recipientVariables: variables
        )
        
        let mailgun = try app.make(MailgunClient.self)
        do {
            let response = try mailgun.send(apiKey: apiKey, domain: domain, message, on: app).wait()
            XCTAssertTrue(response.http.status.code == HTTPStatus.ok.code)
        } catch {
            print(error.localizedDescription)
            XCTFail()
        }
        
    }
    
    func testMailgunCanSendMessageFails() throws {
        let message = MailgunEmail(
            from: "",
            to: [EmailAddress(email: testEmail)],
            text: "This is a newsletter",
            html: "<h1>This is a newsletter</h1>",
            subject: "Newsletter"
            
        )
        
        let mailgun = try app.make(MailgunClient.self)
        do {
            let response = try mailgun.send(apiKey: apiKey, domain: domain, message, on: app).wait()
            XCTFail()
        } catch {
            XCTAssertNotNil(error)
        }
        
    }
    
    func testMailgunCanSendMessageAuthenticationFails() throws {
        let message = MailgunEmail(
            from: "mailgun@sandbox1ae25b0dd717479699708a4953bcec8a.mailgun.org",
            to: [EmailAddress(email: testEmail)],
            text: "This is a newsletter",
            html: "<h1>This is a newsletter</h1>",
            subject: "Newsletter"
            
        )
        
        let mailgun = try app.make(MailgunClient.self)
        do {
            let response = try mailgun.send(apiKey: "badkey", domain: domain, message, on: app).wait()
            XCTFail()
        } catch (MailgunClient.Error.authenticationFailed) {
            
        } catch {
            XCTFail()
        }
        
    }
    
}
