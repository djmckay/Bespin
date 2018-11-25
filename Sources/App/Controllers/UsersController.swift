//
//  UserController.swift
//  App
//
//  Created by DJ McKay on 10/22/18.
//

import Vapor
import Crypto

struct UsersController: BespinController {
    
    typealias T = User
    typealias Public = User.Public
    static var path = "users"
    
    func boot(router: Router) throws {
        let usersRoute = router.grouped(BespinApi.path, UsersController.path)
        //        usersRoute.post(User.self, use: createHandler)
        //        usersRoute.get(use: getAllHandler)
        //        usersRoute.get(User.parameter, use: getAllHandler)
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware, guardAuthMiddleware)
        basicAuthGroup.post(Token.self, at: User.parameter, "generateApiKey", use: generateApiKey)
        basicAuthGroup.get(User.parameter, use: getHandler)
        basicAuthGroup.get("login", use: loginHandler)
        //let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
        //
//                let tokenAuthMiddleware = User.tokenAuthMiddleware()
//                let tokenAuthGroup = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        //        tokenAuthGroup.post(User.self, use: createHandler)
        //        tokenAuthGroup.get(use: getAllHandler)
        //        tokenAuthGroup.get(User.parameter, use: getAllHandler)
        
        usersRoute.post(User.self, use: createHandler)
        let protectedRoutes = usersRoute.grouped(AdminJWTMiddleWareProvider())
        protectedRoutes.get(use: getAllHandler)
        protectedRoutes.delete(User.parameter, use: deleteHandler)
    }
    
    func createHandler(_ req: Request, entity: User) throws -> Future<Public> {
        entity.password = try BCrypt.hash(entity.password)
        return entity.save(on: req).convertToPublic()
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Public]> {
        return T.query(on: req).decode(data: Public.self).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Public> {
        return try req.parameters.next(User.self).convertToPublic()
    }
    
    func generateApiKey(_ req: Request, token: Token) throws -> Future<Token> {
        _ = try req.requireAuthenticated(User.self)
        //let token = try Token.generate(for: user)
        return token.save(on: req)
    }
    
    func loginHandler(_ req: Request) throws -> Public {
        let log: Logger = try req.make(Logger.self)
        log.verbose("login handler")
        let user = try req.requireAuthenticated(User.self)
        log.verbose(user.username)
        return user.convertToPublic()
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<User.Public> {
        return try flatMap(to: T.Public.self,
                           req.parameters.next(T.self),
                           req.content.decode(T.self)) { item, updatedItem in
                            item.password = try BCrypt.hash(item.password)
                            //                            item.short = updatedItem.short
                            //                            item.long = updatedItem.long
                            return item.save(on: req).convertToPublic()
        }
    }
    
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return try req.parameters.next(T.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }

}
