//
//  TemplateManager.swift
//  BespinApp
//
//  Created by DJ McKay on 11/26/18.
//

import Foundation

public class TemplateManager {
    
    static var sharedInstance = TemplateManager()

    
    func getAll(token: Token, complete: @escaping ([Template]?) -> (), failure: @escaping () -> ()) {
        DataManager.sharedInstance.getTemplates(token: token, complete: { [weak self] result in
            switch result {
                
            case .success(let tokens):
                complete(tokens)
            case .failure:
                failure()
            }
        })
    }
    
    func get(token: Token, templateId: String, complete: @escaping (Template?) -> (), failure: @escaping () -> ()) {
        guard let id = UUID(uuidString: templateId) else {
            failure()
            return
        }
        DataManager.sharedInstance.getTemplate(token: token, template: id) { (result) in
            switch result {
                
            case .success(let template):
                complete(template)
            case .failure:
                failure()
            }
        }
    }
    
    func create(token: Token, template: Template, complete: @escaping (Template?) -> (), failure: @escaping () -> ()) {
        DataManager.sharedInstance.createTemplate(token: token, template: template) { result in
            switch result {
                
            case .success(let template):
                complete(template)
            case .failure:
                failure()
            }
            
        }
    }
    
    func delete(token: Token, template: Template, complete: @escaping () -> (), failure: @escaping () -> ()) {
        DataManager.sharedInstance.deleteTemplate(token: token, template: template) { result in
            switch result {
                
            case .success:
                complete()
            case .failure:
                failure()
            }
            
        }
    }
}

