//
//  TokensManager.swift
//  BespinApp
//
//  Created by DJ McKay on 11/25/18.
//

import Foundation

protocol TokenModelUpdated {
    func update()
}

public class TokensManager {
    
    static var sharedInstance = TokensManager()
    var login_session:String = ""
    
    func getTokens(user: User, complete: @escaping ([Token]?) -> (), failure: @escaping () -> ()) {
        DataManager.sharedInstance.getTokens(user: user, complete: { [weak self] result in
            switch result {
                
            case .success(let tokens):
                DataManager.sharedInstance.defaultToken = tokens.first
                complete(tokens)
            case .failure:
                failure()
            }
        })
    }
    
    func generateToken(token: Token, complete: @escaping (Token?) -> ()) {
        DataManager.sharedInstance.generateToken(token: token) { (result) in
            switch result {
                
            case .success(let token):
                complete(token)
            case .failure:
                complete(nil)
            }
        }
    }
    
    func delete(token: Token, complete: @escaping () -> (), failure: @escaping () -> ()) {
        DataManager.sharedInstance.deleteToken(token: token) { result in
            switch result {
                
            case .success:
                complete()
            case .failure:
                failure()
            }
            
        }
    }
    
}
