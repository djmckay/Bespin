//
//  TokenTests.swift
//  AppTests
//
//  Created by DJ McKay on 10/26/18.
//

@testable import App
import Vapor
import XCTest
import FluentMySQL
import JWT
import Crypto

class TokenTests: XCTestCase {
    
    var uri: String = "/api/users/uuid/tokens/"
    var app: Application!
    var conn: MySQLConnection!
    var headers: HTTPHeaders!
    var user: User!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .Bespin).wait()
        user = try! User.create(domain: "sandbox1ae25b0dd717479699708a4953bcec8a.mailgun.org", on: conn)
        headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: "application/json")
        
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTokenCanBeRetrievedFromAPI() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let password = try BCrypt.hash("myPassword")
        let user = try User(name: "testapi", username: "testapi", password: password, domain: "domain.example.com").save(on: conn).wait()
        let creds = BasicAuthorization(username: user.username, password: "myPassword")
        headers.basicAuthorization = creds
        let token = try Token(token: "token1", userID: user.id!).save(on: conn).wait()
        uri = "/api/users/\(user.id!.uuidString)/tokens/"

        let tokens = try app.getResponse(to: uri, headers: headers, decodeTo: [Token].self)
        
        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens[0].token, token.token)
        XCTAssertEqual(tokens[0].id, token.id)
        XCTAssertEqual(tokens[0].userID, token.userID)
    }
    
    func testTokensCanBeRetrievedFromAPI() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let password = try BCrypt.hash("myPassword")
        let user = try User(name: "testapi", username: "testapi", password: password, domain: "domain.example.com").save(on: conn).wait()
        let creds = BasicAuthorization(username: user.username, password: "myPassword")
        headers.basicAuthorization = creds
        let token = try Token(token: "atoken1", userID: user.id!).save(on: conn).wait()
        let token2 = try Token(token: "btoken2", userID: user.id!).save(on: conn).wait()
        let user2 = try User(name: "testapi", username: "otherUser", password: password, domain: "domain.example.com").save(on: conn).wait()
        let token3 = try Token(token: "token3", userID: user2.id!).save(on: conn).wait()

        uri = "/api/users/\(user.id!.uuidString)/tokens/"
        
        let tokens = try app.getResponse(to: uri, headers: headers, decodeTo: [Token].self)
            .sorted(by: { (lhs, rhs) -> Bool in
            return lhs.token < rhs.token
        })
        
        XCTAssertEqual(tokens.count, 2)
        XCTAssertEqual(tokens[0].token, token.token)
        XCTAssertEqual(tokens[0].id, token.id)
        XCTAssertEqual(tokens[0].userID, token.userID)
        
        XCTAssertEqual(tokens[1].token, token2.token)
        XCTAssertEqual(tokens[1].id, token2.id)
        XCTAssertEqual(tokens[1].userID, token2.userID)
        
        uri = "/api/users/\(user2.id!.uuidString)/tokens/"
        
        let otherTokens = try app.getResponse(to: uri, headers: headers, decodeTo: [Token].self)
        
        XCTAssertEqual(otherTokens.count, 1)
        XCTAssertEqual(otherTokens[0].token, token3.token)
        XCTAssertEqual(otherTokens[0].id, token3.id)
        XCTAssertEqual(otherTokens[0].userID, token3.userID)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
