//
//  EmailTemplateAttachmentsController.swift
//  App
//
//  Created by DJ McKay on 7/4/19.
//

import Vapor
import Foundation
import JWT

struct EmailTemplateAttachmentsController: BespinController {
    func createHandler(_ req: Request, entity: EmailTemplateAttachment) throws -> EventLoopFuture<EmailTemplateAttachment> {
        let log: Logger = try req.make(Logger.self)
        log.info("EmailTemplateAttachmentsController.createHandler")
        let id = try req.parameters.next(Token.self)
        log.info("after token")
        log.info(Bespin.Storage_Key)
        log.info(Bespin.Storage_Secret)
        return try req.parameters.next(EmailTemplate.self).flatMap({ (template) -> EventLoopFuture<EmailTemplateAttachment> in
            log.info(template.name)
            entity.templateID = template.id!
            let data = Data(base64Encoded: entity.data)!
            return try Storage.upload(bytes: data, fileName: entity.filename, fileExtension: nil, mime: nil, folder: template.id?.uuidString, access: .authenticatedRead, on: req).flatMap({ (path) -> EventLoopFuture<EmailTemplateAttachment> in
                //TODO: FUTURE STORE THE PATH ONLY
                entity.path = path
                
                log.info(path)
                return entity.save(on: req)
            })
            
        })
    }
    
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[EmailTemplateAttachment]> {
        let id = try req.parameters.next(Token.self)
        return try req.parameters.next(EmailTemplate.self).flatMap({ (template) -> EventLoopFuture<[EmailTemplateAttachment]> in
            return try template.attachments.query(on: req).all()
        })
    }
    
    func getHandler(_ req: Request) throws -> EventLoopFuture<EmailTemplateAttachment> {
        let id = try req.parameters.next(Token.self)
        return try req.parameters.next(T.self).convertToPublic()
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<EmailTemplateAttachment> {
        let id = try req.parameters.next(Token.self)
        print(id)
        return try flatMap(to: T.self,
                           req.parameters.next(T.self),
                           req.content.decode(T.self)) { item, updatedItem in
                            item.filename = updatedItem.filename
                            item.data = updatedItem.data
                            return item.save(on: req)
        }
    }
    
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let id = try req.parameters.next(Token.self)
        _ = try req.parameters.next(EmailTemplate.self)
        return try req.parameters.next(T.self).delete(on: req).transform(to: HTTPStatus.noContent)
    }
    
    typealias T = EmailTemplateAttachment
    
    typealias Public = EmailTemplateAttachment
    
    func boot(router: Router) throws {
        let route = router.grouped(BespinApi.path, Token.parameter, EmailTemplateController.path, EmailTemplate.parameter, EmailTemplateAttachmentsController.path)
        let protectedRoutes = route.grouped(JWTMiddleWareProvider())
        protectedRoutes.get(T.parameter, use: getHandler)
        protectedRoutes.get(use: getAllHandler)
        protectedRoutes.post(T.self, use: createHandler)
        protectedRoutes.put(T.parameter, use: updateHandler)
        protectedRoutes.delete(T.parameter, use: deleteHandler)
    }
    
    static var path: String = "attachments"

}


public struct Attachment: Content {
    var id: UUID?
    var templateID: EmailTemplate.ID
    var filename: String
    var data: Data
    var path: String?
}
