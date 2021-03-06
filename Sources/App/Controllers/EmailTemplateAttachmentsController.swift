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
        let id = try req.parameters.next(Token.self)
        return try req.parameters.next(EmailTemplate.self).flatMap({ (template) -> EventLoopFuture<EmailTemplateAttachment> in
            log.info(template.name)
            entity.templateID = template.id!
            let data = Data(base64Encoded: entity.data!)!
            return try Storage.upload(bytes: data, fileName: entity.filename, fileExtension: nil, mime: nil, folder: template.id?.uuidString, access: .privateAccess, on: req).flatMap({ (path) -> EventLoopFuture<EmailTemplateAttachment> in
                //TODO: FUTURE STORE THE PATH ONLY
                entity.path = path
                entity.data = nil
                log.info(path)
                return entity.save(on: req)
            })
            
        })
    }
    
    func getAllHandlerAsAttachment(_ req: Request) throws -> EventLoopFuture<[Attachment]> {
        let id = try req.parameters.next(Token.self)
        let log: Logger = try req.make(Logger.self)
        return try req.parameters.next(EmailTemplate.self).flatMap({ (template) -> EventLoopFuture<[Attachment]> in
            return try template.attachments.query(on: req).all().flatMap({ (attachments) -> EventLoopFuture<[Attachment]> in
                var storageResults: [Future<Attachment>] = []
                try attachments.forEach({ (attachment) in
                    if let path = attachment.path {
                        
                        let storageData = try Storage.get(path: path, on: req).flatMap({ (bytes) -> EventLoopFuture<Attachment> in
                            log.info("Storage get bytes: \(bytes.count)")
                            return req.future(Attachment(id: attachment.id, templateID: attachment.templateID, filename: attachment.filename, data: Data(bytes), path: attachment.path))
                        }).catch({ (error) in
                            
                        })
                        storageResults.append(storageData)
                    }
                })
                return storageResults.flatten(on: req)
            })
        })
    }
    
    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[EmailTemplateAttachment]> {
        let id = try req.parameters.next(Token.self)
        let log: Logger = try req.make(Logger.self)
        return try req.parameters.next(EmailTemplate.self).flatMap({ (template) -> EventLoopFuture<[EmailTemplateAttachment]> in
            return try template.attachments.query(on: req).all().flatMap({ (attachments) -> EventLoopFuture<[EmailTemplateAttachment]> in
                var storageResults: [Future<EmailTemplateAttachment>] = []
                try attachments.forEach({ (attachment) in
                    if let path = attachment.path {
                        
                        let storageData = try Storage.get(path: path, on: req).flatMap({ (bytes) -> EventLoopFuture<String?> in
                            log.info("Storage get bytes: \(bytes.count)")
                            let data = Data(bytes: bytes, count: bytes.count)
                            return req.future(data.base64EncodedString())
                        }).flatMap({ (string) -> EventLoopFuture<EmailTemplateAttachment> in
                            if let string = string {
                                attachment.data = string
                            }
                            log.info("Attachment: \(attachment)")
                            return req.future(attachment)
                        })
                        storageResults.append(storageData)
                    }
                })
                return storageResults.flatten(on: req)
                //return req.future(attachments)
            })
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
                            
                            let data = Data(base64Encoded: updatedItem.data!)!
                            return try Storage.upload(bytes: data, fileName: updatedItem.filename, fileExtension: nil, mime: nil, folder: item.templateID.uuidString, access: .privateAccess, on: req).flatMap({ (path) -> EventLoopFuture<EmailTemplateAttachment> in
                                //TODO: FUTURE STORE THE PATH ONLY
                                item.path = path
                                item.data = nil
                                item.filename = updatedItem.filename
                                return item.save(on: req)
                            })
                            
        }
    }
    
    func deleteHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let id = try req.parameters.next(Token.self)
        _ = try req.parameters.next(EmailTemplate.self)
        
        return try req.parameters.next(T.self).flatMap({ (attachment) -> EventLoopFuture<HTTPStatus> in
            if let path = attachment.path {
                return try attachment.delete(on: req).flatMap({ () -> EventLoopFuture<HTTPStatus> in
                    return try Storage.delete(path: path, on: req).transform(to: HTTPStatus.noContent)
                })
                
            } else {
                return attachment.delete(on: req).transform(to: .noContent)
            }
        })
        
    }
    
    typealias T = EmailTemplateAttachment
    
    typealias Public = EmailTemplateAttachment
    
    func boot(router: Router) throws {
        let route = router.grouped(BespinApi.path, Token.parameter, EmailTemplateController.path, EmailTemplate.parameter, EmailTemplateAttachmentsController.path)
        let protectedRoutes = route.grouped(JWTMiddleWareProvider())
        protectedRoutes.get(T.parameter, use: getHandler)
        protectedRoutes.get(use: getAllHandlerAsAttachment)
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
