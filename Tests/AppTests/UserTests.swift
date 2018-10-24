//
//  UserTests.swift
//  AppTests
//
//  Created by DJ McKay on 10/22/18.
//

@testable import App
import Vapor
import XCTest
import FluentMySQL
import JWT
import Crypto

final class UserTests: XCTestCase {

    var uri: String = "/api/users/"
    var app: Application!
    var conn: MySQLConnection!
    var headers: HTTPHeaders!
    
    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .Bespin).wait()
        //headers = app.defaultHeaders()
//        let token = try? Token.generate(on: conn)
//        uri = "/api/\(token!.id!.uuidString)/templates/"
//
//        // create payload
//        let webToken = WebToken(name: "name", key: "1234567890", domain: "bespin.something.com")
//
//        // create JWT and sign
//        let jwt = try! JWT(payload: webToken).sign(using: .hs256(key: token!.token))
        headers = HTTPHeaders()
//        headers.add(name: .authorization, value: "Bearer \(String(data: jwt, encoding: .utf8) ?? "")")
        headers.add(name: "Content-Type", value: "application/json")
        
        
    }
    
    override func tearDown() {
        conn.close()
    }
    
    func testUserCanSaveTokenWithAPI() throws {
        let password = try BCrypt.hash("myPassword")
        let user = try User(name: "testapi", username: "testapi", password: password, domain: "domain.example.com").save(on: conn).wait()
        let token = Token(token: "123", userID: user.id!)
        let apiUri = uri+user.id!.uuidString+"/generateApiKey/"
        let creds = BasicAuthorization(username: user.username, password: "myPassword")
        headers.basicAuthorization = creds
        let receivedToken = try app.getResponse(to: apiUri, method: .POST, headers: headers, data: token, decodeTo: Token.Public.self)
        XCTAssertEqual(receivedToken.token, token.token)
        XCTAssertNotNil(receivedToken.id)
    }
    
    func testUserCanSaveTokenWithAPIFails() throws {
        let password = try BCrypt.hash("myPassword")
        let user = try User(name: "testapi", username: "testapi", password: password, domain: "domain.example.com").save(on: conn).wait()
        let token = Token(token: "123", userID: user.id!)
        let apiUri = uri+user.id!.uuidString+"/generateApiKey/"
        let creds = BasicAuthorization(username: user.username, password: "myPassword1")
        headers.basicAuthorization = creds
        let receivedToken = try app.sendRequest(to: apiUri, method: .POST, headers: headers, body: token)
        XCTAssertTrue(receivedToken.http.status == .unauthorized)
    }
    
    func testUserCanBeSavedWithAPI() throws {
        let user = User(name: "testapi", username: "testapi", password: "myPassword", domain: "domain.example.com")
        
        let receivedUser = try app.getResponse(to: uri, method: .POST, headers: headers, data: user, decodeTo: User.Public.self)
        
        XCTAssertEqual(receivedUser.name, user.name)
        XCTAssertEqual(receivedUser.username, user.username)
        XCTAssertEqual(receivedUser.domain, user.domain)
        XCTAssertNotNil(receivedUser.id)
        

    }
    
    func testUserCanBeSavedWithAPIFails() throws {
        let user = User(name: "testapi", username: "testapi", password: "myPassword", domain: "domain.example.com")
        
        let receivedUser = try app.getResponse(to: uri, method: .POST, headers: headers, data: user, decodeTo: User.Public.self)
        
        XCTAssertEqual(receivedUser.name, user.name)
        XCTAssertEqual(receivedUser.username, user.username)
        XCTAssertEqual(receivedUser.domain, user.domain)
        XCTAssertNotNil(receivedUser.id)
        
        let user2 = User(name: "testapi2", username: "testapi", password: "myPassword", domain: "domain.example.com")
        
        let receivedUser2 = try app.sendRequest(to: uri, method: .POST, headers: headers, body: user2)
        XCTAssertTrue(receivedUser2.http.status == .internalServerError)
    }
    
//    func testUserCanGenerateAPIKey() throws {
//        let user = User(name: "testapi", username: "testapi", password: "myPassword", domain: "domain.example.com")
//        
//        let receivedUser = try app.getResponse(to: uri, method: .POST, headers: headers, data: user, decodeTo: User.Public.self)
//        
//        XCTAssertEqual(receivedUser.name, user.name)
//        XCTAssertEqual(receivedUser.username, user.username)
//        XCTAssertEqual(receivedUser.domain, user.domain)
//        XCTAssertNotNil(receivedUser.id)
//        
//        let token = try app.getResponse(to: uri+"generateApiKey/", headers: headers, decodeTo: [Token].self)
//
//        XCTAssertEqual(token.count, 1)
//        
//    }
}
