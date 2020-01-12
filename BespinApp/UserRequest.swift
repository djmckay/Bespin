//
//  TokenRequest.swift
//  BespinApp
//
//  Created by DJ McKay on 11/25/18.
//

import Foundation

//enum TokenUserRequestResult {
//    case success(User)
//    case failure
//}



struct UserRequest {
    let resource: URL
    let userID: String!
    
    init(userID: UUID) {
        let resourceString = "https://djmckay-tech-bespin.herokuapp.com/api/users/\(userID.uuidString)"
        guard let resourceURL = URL(string: resourceString) else {
            fatalError()
        }
        self.userID = userID.uuidString
        self.resource = resourceURL
    }
    
    func getTokens(completion: @escaping (GetResourcesRequest<Token>) -> Void) {
        
        let request = ResourceRequest<Token>(resourcePath: "users/\(userID!)/tokens")
        request.getAll { (result) in
            completion(result)
        }
        

    }
    
    func generateToken(token: Token, completion: @escaping (SaveResult<Token>) -> Void) {
        let request = ResourceRequest<Token>(resourcePath: "users/\(token.userID.uuidString)/generateApiKey")
        request.save(token) { (result) in
            completion(result)
        }

    }
    
    func deleteToken(token: Token, completion: @escaping (DeleteResult<Token>) -> Void) {
        guard let id = token.id else {
            completion(.failure)
            return
        }
        let request = ResourceRequest<Token>(resourcePath: "users/\(token.userID.uuidString)/tokens/\(id)")
        request.delete() { (result) in
            completion(result)
        }
    }
    
    func update(user: User, completion: @escaping (SaveResult<User>) -> Void) {
        var path = "users"
        if let id = user.id?.uuidString {
            path = path.appending("/\(id)")
        }
        let request = ResourceRequest<User>(resourcePath: path)
        request.update(user) { (result) in
            completion(result)
        }
        
    }
    
    func changePassword(user: User, completion: @escaping (SaveResult<User>) -> Void) {
        var path = "users"
        if let id = user.id?.uuidString {
            path = path.appending("/\(id)/changePassword")
        }
        let request = ResourceRequest<User>(resourcePath: path)
        request.update(user) { (result) in
            completion(result)
        }
        
    }
    
}
