//
//  BespinController.swift
//  App
//
//  Created by DJ McKay on 10/19/18.
//

import Foundation
import Vapor
import JWT
import Fluent

struct BespinApi {
    static var path:String = "api"
    
}
protocol BespinController: RouteCollection {
    associatedtype T
    associatedtype Public
    static var path: String { get }
    func createHandler(_ req: Request, entity: T) throws -> Future<Public>
    func getAllHandler(_ req: Request) throws -> Future<[Public]>
    func getHandler(_ req: Request) throws -> Future<Public>
    func updateHandler(_ req: Request) throws -> Future<Public>
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus>
}


struct WebToken: JWTPayload {
    var name: String
    var key: String
    var domain: String
    
    func verify(using signer: JWTSigner) throws {
        // nothing to verify
        print("nothing to verify")
        print(self.key)
    }
}

class JWTMiddleWareProvider: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        guard let bearer = request.http.headers.bearerAuthorization else {
            throw Abort(.unauthorized)
        }
//        let unverified = try JWT<WebToken>(from: bearer.token)
//        print(unverified.header.kid)
//        guard let kid = unverified.header.kid else {
//            throw Abort(.unauthorized)
//        }
        print(request.parameters.rawValues(for: Token.self))
        let kid = request.parameters.rawValues(for: Token.self).first!
//        return try request.parameters.next(Token.self).flatMap({ (token) -> EventLoopFuture<Response> in
//            _ = try JWT<WebToken>(from: bearer.token, verifiedUsing: .hs256(key: token.token))
//            return try next.respond(to: request)
//        })
        let id = UUID(uuidString: kid)
        return Token.query(on: request).filter(\.id == id).first().flatMap { (token) -> EventLoopFuture<Response> in
            // parse JWT from token string, using HS-256 signer
            guard let token = token?.token else {
                throw Abort(.unauthorized)
            }
            _ = try JWT<WebToken>(from: bearer.token, verifiedUsing: .hs256(key: token))
            return try next.respond(to: request)

        }
        
    }
}

struct AdminToken: JWTPayload {
    var key: String
    
    func verify(using signer: JWTSigner) throws {
        // nothing to verify
        print("nothing to verify")
    }
}

class AdminJWTMiddleWareProvider: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        guard let bearer = request.http.headers.bearerAuthorization else {
            throw Abort(.unauthorized)
        }
        // parse JWT from token string, using HS-256 signer
        let token = try JWT<AdminToken>(from: bearer.token, verifiedUsing: .hs256(key: Environment.get("ADMIN_TOKEN") ?? "secret"))
        
        return try next.respond(to: request)
        
    }
}
