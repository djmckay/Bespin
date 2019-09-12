//
//  TemplateAttachmentManager.swift
//  BespinApp
//
//  Created by DJ McKay on 7/4/19.
//

import Foundation

public class TemplateAttachmentManager {
    
    static var sharedInstance = TemplateAttachmentManager()
    
    
    func getAll(token: Token, template: Template, complete: @escaping ([Template.Attachment]?) -> (), failure: @escaping () -> ()) {
        DataManager.sharedInstance.getTemplateAttachments(token: token, template: template, complete: { [weak self] result in
            switch result {

            case .success(let attachments):
                complete(attachments)
            case .failure:
                failure()
            }
        })
    }
    
//    func get(token: Token, templateId: String, complete: @escaping (Template.Attachment?) -> (), failure: @escaping () -> ()) {
//        guard let id = UUID(uuidString: templateId) else {
//            failure()
//            return
//        }
//        DataManager.sharedInstance.getTemplate(token: token, template: id) { (result) in
//            switch result {
//
//            case .success(let template):
//                complete(template)
//            case .failure:
//                failure()
//            }
//        }
//    }
    
    func create(token: Token, attachment: Template.Attachment, complete: @escaping (Template.Attachment?) -> (), failure: @escaping () -> ()) {
        DataManager.sharedInstance.createTemplateAttachment(token: token, attachment: attachment) { result in
            switch result {
                
            case .success(let attachment):
                complete(attachment)
            case .failure:
                failure()
            }
            
        }
    }
    
    func delete(token: Token, attachment: Template.Attachment, complete: @escaping () -> (), failure: @escaping () -> ()) {
        DataManager.sharedInstance.deleteTemplateAttachment(token: token, attachment: attachment) { result in
            switch result {

            case .success:
                complete()
            case .failure:
                failure()
            }

        }
    }
}

