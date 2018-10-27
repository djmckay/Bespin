//
//  EmailTemplateTests.swift
//  App
//
//  Created by DJ McKay on 10/20/18.
//

@testable import App
import Vapor
import XCTest
import FluentMySQL
import JWT

final class EmailTemplateTests: XCTestCase {
    
    var uri: String = "/api/uuid/templates/"
    var app: Application!
    var conn: MySQLConnection!
    var headers: HTTPHeaders!
    
    let expectedName = "Template1"
    let expectedText = "Hello this is text"
    let expectedHtml = "<b>Hello this is html</b>"
    var user: User!
    
    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .Bespin).wait()
        //headers = app.defaultHeaders()
        let token = try? Token.generate(on: conn)
        user = try? token!.user.query(on: conn).first().wait()!
        uri = "/api/\(token!.id!.uuidString)/templates/"
        
        // create payload
        let webToken = WebToken(name: "name", key: "1234567890", domain: "bespin.something.com")
        
        // create JWT and sign
        let jwt = try! JWT(payload: webToken).sign(using: .hs256(key: token!.token))
        headers = HTTPHeaders()
        headers.add(name: .authorization, value: "Bearer \(String(data: jwt, encoding: .utf8) ?? "")")
        headers.add(name: "Content-Type", value: "application/json")
        
    }
    
    override func tearDown() {
        conn.close()
    }
    
    func testsEmailTemplatesCanBeRetrievedFromAPI() throws {
        
        let template = EmailTemplate(name: expectedName, text: expectedText, html: expectedHtml, userID: user.id!)
        
        let savedTemplate = try template.save(on: conn).wait()
        
        _ = try EmailTemplate.create(user: user, on: conn)
 
        let templates = try app.getResponse(to: uri, headers: headers, decodeTo: [EmailTemplate].self)
        
        XCTAssertEqual(templates.count, 2)
        XCTAssertEqual(templates[0].name, expectedName)
        XCTAssertEqual(templates[0].text, expectedText)
        XCTAssertEqual(templates[0].html, expectedHtml)
        XCTAssertEqual(templates[0].id, savedTemplate.id)
        
    }
    
    func testTemplateCanBeSavedWithAPI() throws {
        let template = EmailTemplate(name: "savedTemplate", text: "text for saved template", html: "html for saved template", userID: user.id!)
        
        let receivedTemplate = try app.getResponse(to: uri, method: .POST, headers: headers, data: template, decodeTo: EmailTemplate.self)
        
        XCTAssertEqual(receivedTemplate.name, template.name)
        XCTAssertEqual(receivedTemplate.text, template.text)
        XCTAssertEqual(receivedTemplate.html, template.html)
        XCTAssertNotNil(receivedTemplate.id)
        
        let templates = try app.getResponse(to: uri, headers: headers, decodeTo: [EmailTemplate].self)
        
        XCTAssertEqual(templates.count, 1)
        XCTAssertEqual(templates[0].name, receivedTemplate.name)
        XCTAssertEqual(templates[0].html, receivedTemplate.html)
        XCTAssertEqual(templates[0].text, receivedTemplate.text)
        XCTAssertEqual(templates[0].id, receivedTemplate.id)
    }
    
    func testGettingASingleUserFromTheAPI() throws {
        
        let template = try EmailTemplate.create(name: expectedName, text: expectedText, html: expectedHtml, user: user, on: conn)
        let receivedTemplate = try app.getResponse(to: "\(uri)\(template.id!)",headers: headers, decodeTo: EmailTemplate.self)
        
        XCTAssertEqual(receivedTemplate.name, expectedName)
        XCTAssertEqual(receivedTemplate.text, expectedText)
        XCTAssertEqual(receivedTemplate.html, expectedHtml)
        XCTAssertEqual(receivedTemplate.id, template.id)
    }
    
    func testUpdatingASingleUserFromTheAPI() throws {
        
        let template = try EmailTemplate.create(name: expectedName, text: expectedText, html: expectedHtml, user: user, on: conn)
        let receivedTemplate = try app.getResponse(to: "\(uri)\(template.id!)",headers: headers, decodeTo: EmailTemplate.self)
        
        XCTAssertEqual(receivedTemplate.name, expectedName)
        XCTAssertEqual(receivedTemplate.text, expectedText)
        XCTAssertEqual(receivedTemplate.html, expectedHtml)
        XCTAssertEqual(receivedTemplate.id, template.id)
        
        receivedTemplate.text = "Updated Text"
        receivedTemplate.html = "Updated HTML"
        receivedTemplate.name = "Updated Name"
        
        let updatedTemplate = try app.getResponse(to: "\(uri)\(template.id!)", method: .PUT, headers: headers, data: receivedTemplate, decodeTo: EmailTemplate.self)
        
        XCTAssertEqual(updatedTemplate.name, receivedTemplate.name)
        XCTAssertEqual(updatedTemplate.text, receivedTemplate.text)
        XCTAssertEqual(updatedTemplate.html, receivedTemplate.html)
        XCTAssertEqual(updatedTemplate.id, receivedTemplate.id)
    }
    
    func testsEmailTemplatesCanBeDeletedFromAPI() throws {
        
        let template = try EmailTemplate.create(name: expectedName, text: expectedText, html: expectedHtml, user: user, on: conn)
        var templates = try app.getResponse(to: uri,headers: headers, decodeTo: [EmailTemplate].self)
        
        XCTAssertEqual(templates.count, 1)
        
        _ = try app.sendRequest(to: "\(uri)\(template.id!)", method: HTTPMethod.DELETE, headers: headers)
        templates = try app.getResponse(to: uri,headers: headers, decodeTo: [EmailTemplate].self)
        XCTAssertEqual(templates.count, 0)
        
    }
    
    func testGetAllTemplatesWithAPI() throws {
        let template = try EmailTemplate(name: "savedTemplate", text: "text for saved template", html: "html for saved template", userID: user.id!).save(on: conn).wait()
        let template2 = try EmailTemplate(name: "savedTemplate2", text: "text for saved template 2", html: "html for saved template 2", userID: user.id!).save(on: conn).wait()
        let template3 = try EmailTemplate(name: "savedTemplate3", text: "text for saved template 3", html: "html for saved template 3", userID: try User.create(username: "bespin2", on: conn).id!).save(on: conn).wait()
        let templates = try app.getResponse(to: uri, headers: headers, decodeTo: [EmailTemplate].self)
        
        XCTAssertEqual(templates.count, 2)
        XCTAssertEqual(templates[0].name, template.name)
        XCTAssertEqual(templates[0].html, template.html)
        XCTAssertEqual(templates[0].text, template.text)
        XCTAssertEqual(templates[0].id, template.id)
        
        XCTAssertEqual(templates[1].name, template2.name)
        XCTAssertEqual(templates[1].html, template2.html)
        XCTAssertEqual(templates[1].text, template2.text)
        XCTAssertEqual(templates[1].id, template2.id)
    }
    
}
