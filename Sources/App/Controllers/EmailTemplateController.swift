//
//  EmailTemplateController.swift
//  App
//
//  Created by DJ McKay on 10/19/18.
//

import Vapor
import Foundation
import JWT

struct EmailTemplateController: BespinController {
    static var path: String = "templates"
    
    func createHandler(_ req: Request, entity: EmailTemplate) throws -> EventLoopFuture<EmailTemplate> {
//        let id = try req.parameters.next(Token.self)
//        print(id)
        let bearer = req.http.headers.bearerAuthorization!
        
        // parse JWT from token string, using HS-256 signer
//        let unverified = try JWT<WebToken>(from: bearer.token)
//        print(unverified.header.kid)
//        let jwt = try JWT<WebToken>(from: bearer.token, verifiedUsing: .hs256(key: "secret"))
//        jwt.payload.domain
        
        return try req.parameters.next(Token.self).flatMap({ (token) -> EventLoopFuture<EmailTemplate> in
            let jwt = try JWT<WebToken>(from: bearer.token, verifiedUsing: .hs256(key: token.token))
            print(jwt.payload.domain)
            entity.userID = token.userID
            return entity.save(on: req).convertToPublic()
        })
        
//        return entity.save(on: req).convertToPublic()
    }
    
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[EmailTemplate]> {
        return try req.parameters.next(Token.self).flatMap({ (token) -> EventLoopFuture<[EmailTemplate]> in
            return token.user.get(on: req).flatMap({ (user) -> EventLoopFuture<[EmailTemplate]> in
                return try user.templates.query(on: req).all()
                //return T.query(on: req).decode(data: Public.self).all()
            })
        })
        
        //EmailTemplate.find(id, on: req).flatMap({ (template) -> EventLoopFuture<Response> in
//        let id = try req.parameters.next(Token.self)
//        print(id)
        
    }
    
    func getHandler(_ req: Request) throws -> EventLoopFuture<EmailTemplate> {
        let id = try req.parameters.next(Token.self)
        print(id)
        return try req.parameters.next(T.self).convertToPublic()
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<EmailTemplate> {
        let id = try req.parameters.next(Token.self)
        print(id)
        return try flatMap(to: T.self,
                           req.parameters.next(T.self),
                           req.content.decode(T.self)) { item, updatedItem in
                            item.name = updatedItem.name
                            item.text = updatedItem.text
                            item.html = updatedItem.html
                            item.subject = updatedItem.subject
                            return item.save(on: req)
        }
    }
    
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let id = try req.parameters.next(Token.self)
        print(id)
        return try req.parameters.next(T.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
    
    typealias T = EmailTemplate
    
    typealias Public = EmailTemplate
    
    func boot(router: Router) throws {
        let route = router.grouped(BespinApi.path, Token.parameter, EmailTemplateController.path)
        let protectedRoutes = route.grouped(JWTMiddleWareProvider())
        protectedRoutes.get(T.parameter, use: getHandler)
        protectedRoutes.get(use: getAllHandler)
        protectedRoutes.post(T.self, use: createHandler)
        protectedRoutes.put(T.parameter, use: updateHandler)
        protectedRoutes.delete(T.parameter, use: deleteHandler)
        
    }
    

}

extension JWT {
    
    /// Parses a JWT string into a JSON Web Signature
    public init(from data: LosslessDataConvertible) throws {
        let parts = data.convertToData().split(separator: .period)
        guard parts.count == 3 else {
            throw JWTError(identifier: "invalidJWT", reason: "Malformed JWT")
        }
        
        let headerData = Data(parts[0])
        let payloadData = Data(parts[1])
        let signatureData = Data(parts[2])
        
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .secondsSince1970
        
        guard let decodedHeader = Data(base64URLEncoded: headerData) else {
            throw JWTError(identifier: "base64", reason: "JWT header is not valid base64-url")
        }
        guard let decodedPayload = Data(base64URLEncoded: payloadData) else {
            throw JWTError(identifier: "base64", reason: "JWT payload is not valid base64-url")
        }
        
        self.header = try jsonDecoder.decode(JWTHeader.self, from: decodedHeader)
        self.payload = try jsonDecoder.decode(Payload.self, from: decodedPayload)
    }
    
    func verify(verifiedUsing signer: JWTSigner) {
        
    }
    
}
