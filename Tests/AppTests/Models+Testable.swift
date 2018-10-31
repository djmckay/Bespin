//
//  Models+Testable.swift
//  App
//
//  Created by DJ McKay on 10/20/18.
//

@testable import App
import FluentMySQL
import Vapor
import Crypto

extension EmailTemplate {
    static func create(name: String = "otherTemplate", text: String = "Other text", html: String = "Other html", subject: String? = nil, user: User, on connection: MySQLConnection) throws -> EmailTemplate {
        let template = EmailTemplate(name: name, text: text, html: html, userID: user.id!)
        template.subject = subject
        return try template.save(on: connection).wait()
    }
}

extension Token {
    static func create(on connection: MySQLConnection) throws -> Token {
        let user = try User.create(on: connection)
        let token = Token(token: "secret", userID: user.id!)
        return try token.save(on: connection).wait()
    }
    
    static func generate(on connection: MySQLConnection) throws -> Token {
        let user = try User.create(on: connection)
        let token = try Token.generate(for: user)
        return try token.save(on: connection).wait()
    }
}

extension User {
    static func create(name: String = "bespin", username: String = "bespin", password: String = "bespin", domain: String = "bespin.something.com", on connection: MySQLConnection) throws -> User {
        let hashedPassword = try BCrypt.hash(password)
        let user = User(name: name, username: username, password: hashedPassword, domain: domain)
        return try user.save(on: connection).wait()
    }
}
