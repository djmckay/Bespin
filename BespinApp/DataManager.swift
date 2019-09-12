//
//  DataManager.swift
//  BespinApp
//
//  Created by DJ McKay on 11/25/18.
//

import Foundation

class DataManager {
    
    static var sharedInstance = DataManager()
    
    let userRequest = ResourceRequest<User>(resourcePath: "users")
    
    var currentUser: User? {
        get {
            return Auth.auth().currentUser
        }
    }
    
    var basicAuthorization: String? {
        get {
            return Auth.auth().basicAuthorization
        }
    }
    
    var defaultToken: Token?
    
    public func registerUser(user: User, complete: @escaping (SaveResult<User>) -> ()) {
        userRequest.save(user) { [weak self] result in
            complete(result)
        }
    }
    
    public func updateUser(user: User, complete: @escaping (SaveResult<User>) -> ()) {
        guard let id = user.id else { complete(SaveResult.failure); return }
        let userRequest = UserRequest(userID: id)
        userRequest.update(user: user) { [weak self] result in
            complete(result)
        }
    }
    
    public func changePassword(user: User, complete: @escaping (SaveResult<User>) -> ()) {
        guard let id = user.id else { complete(SaveResult.failure); return }
        let userRequest = UserRequest(userID: id)
        userRequest.changePassword(user: user) { [weak self] result in
            complete(result)
        }
    }
    
    public func getTokens(user: User, complete: @escaping (GetResourcesRequest<Token>)->()) {
        guard let id = user.id else { return }
        let tokenRequest = UserRequest(userID: id)
        tokenRequest.getTokens { (result) in
            complete(result)
        }
    }
    
    public func generateToken(token: Token, complete: @escaping (SaveResult<Token>)->()) {
        let tokenRequest = UserRequest(userID: token.userID)
        tokenRequest.generateToken(token: token) { (result) in
            complete(result)
        }
    }
    
    func createTemplate(token: Token, template: Template, complete: @escaping (SaveResult<Template>) -> ()) {
        guard token.id != nil else { complete(SaveResult.failure); return }
        let tokenRequest = TokenRequest(token: token)
        tokenRequest.saveTemplate(template: template) { (results) in
            complete(results)
        }
    }

    public func getTemplates(token: Token, complete: @escaping (GetResourcesRequest<Template>)->()) {
        guard token.id != nil else { complete(GetResourcesRequest.failure); return }
        let tokenRequest = TokenRequest(token: token)
        tokenRequest.getTemplates { (results) in
            complete(results)
        }
    }
    
    func deleteTemplate(token: Token, template: Template, complete: @escaping (DeleteResult<Template>) -> ()) {
        guard token.id != nil else { complete(DeleteResult.failure); return }
        let tokenRequest = TokenRequest(token: token)
        tokenRequest.deleteTemplate(template: template) { (results) in
            complete(results)
        }
    }
    
    func deleteToken(token: Token, complete: @escaping (DeleteResult<Token>) -> ()) {
        let tokenRequest = UserRequest(userID: token.userID)
        tokenRequest.deleteToken(token: token) { (result) in
            complete(result)
        }
    }
    
    func getTemplate(token: Token, template: UUID, complete: @escaping (GetResourceRequest<Template>) -> ()) {
        guard token.id != nil else { complete(GetResourceRequest.failure); return }
        let tokenRequest = TokenRequest(token: token)
        tokenRequest.getTemplate(templateId: template) { (result) in
            complete(result)
        }
    }
    
    func createTemplateAttachment(token: Token, attachment: Template.Attachment, complete: @escaping (SaveResult<Template.Attachment>) -> ()) {
        guard token.id != nil else { complete(SaveResult.failure); return }
        let tokenRequest = TokenRequest(token: token)
        tokenRequest.saveTemplateAttachment(attachment: attachment) { (results) in
            complete(results)
        }
    }
    
    public func getTemplateAttachments(token: Token, template: Template, complete: @escaping (GetResourcesRequest<Template.Attachment>)->()) {
        guard token.id != nil else { complete(GetResourcesRequest.failure); return }
        let tokenRequest = TokenRequest(token: token)
        tokenRequest.getTemplateAttachments(template: template) { (results) in
            complete(results)
        }
    }
    
    public func deleteTemplateAttachment(token: Token, attachment: Template.Attachment, complete: @escaping (DeleteResult<Template.Attachment>)->()) {
        guard token.id != nil else { complete(DeleteResult.failure); return }
        let tokenRequest = TokenRequest(token: token)
        tokenRequest.deleteTemplateAttachment(attachment: attachment) { (results) in
            complete(results)
        }
    }
}
