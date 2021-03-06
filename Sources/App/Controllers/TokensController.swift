//
//  TokensController.swift
//  App
//
//  Created by DJ McKay on 10/22/18.
//

import Vapor
import Crypto

struct TokensController: BespinController {
    
    typealias T = Token
    typealias Public = Token.Public
    static var path = "tokens"
    
    func boot(router: Router) throws {
        let route = router.grouped(BespinApi.path, UsersController.path, User.parameter, TokensController.path)
        //        usersRoute.post(User.self, use: createHandler)
        //        usersRoute.get(use: getAllHandler)
        //        usersRoute.get(User.parameter, use: getAllHandler)
        //        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        //        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
        //        basicAuthGroup.post("login", use: loginHandler)
        //
        //        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        //        let guardAuthMiddleware = User.guardAuthMiddleware()
        //        let tokenAuthGroup = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        //        tokenAuthGroup.post(User.self, use: createHandler)
        //        tokenAuthGroup.get(use: getAllHandler)
        //        tokenAuthGroup.get(User.parameter, use: getAllHandler)
        
        //route.post(Token.self, use: createHandler)
        //let protectedRoutes = route.grouped(JWTMiddleWareProvider())
        //protectedRoutes.post(User.parameter, use: getAllHandler)
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let basicAuthGroup = route.grouped(basicAuthMiddleware, guardAuthMiddleware)
        basicAuthGroup.get(use: getAllHandler)
        basicAuthGroup.delete(Token.parameter, use: deleteHandler)
    }
    
    func createHandler(_ req: Request, entity: Token) throws -> Future<Public> {
        let loggedInUser = try req.requireAuthenticated(User.self)
        entity.userID = loggedInUser.id!
        return entity.save(on: req)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Public]> {
        let id = try req.parameters.next(User.self)
        return id.flatMap({ (user) -> EventLoopFuture<[Public]> in
            let loggedInUser = try req.requireAuthenticated(User.self)
            guard loggedInUser.id == user.id else { throw  Abort(.forbidden, reason: "No user") }
            return try user.tokens.query(on: req).decode(Public.self).all()
            //return T.query(on: req).decode(data: Public.self).all()
        })
        
    }
    
    func getHandler(_ req: Request) throws -> Future<Public> {
        return try req.parameters.next(T.self)
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<T.Public> {
        return try flatMap(to: T.Public.self,
                           req.parameters.next(T.self),
                           req.content.decode(T.self)) { item, updatedItem in
                            let loggedInUser = try req.requireAuthenticated(User.self)
                            guard loggedInUser.id == item.userID else { throw  Abort(.forbidden, reason: "No user") }
                            return item.save(on: req)
        }
    }
    
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let id = try req.parameters.next(User.self)
        return id.flatMap({ (user) -> EventLoopFuture<HTTPStatus> in
            let loggedInUser = try req.requireAuthenticated(User.self)
            guard loggedInUser.id == user.id else { throw  Abort(.forbidden, reason: "No user") }
            return try req.parameters.next(T.self).delete(on: req).transform(to: HTTPStatus.noContent)
        })
        
        
    }
    
}
