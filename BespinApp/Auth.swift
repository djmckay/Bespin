//
//  Auth.swift
//  BespinApp
//
//  Created by DJ McKay on 11/25/18.
//

import Foundation

enum AuthRequestResult {
    case success(User)
    case failure(AuthError)
}

public enum AuthError: Error {
    
    /// Encoding problem
    case encodingProblem
    
    /// Failed authentication
    case authenticationFailed
    
    /// Generic error
    case unknownError(String)
    
    /// Identifier
    public var identifier: String {
        switch self {
        case .encodingProblem:
            return "encoding_error"
        case .authenticationFailed:
            return "auth_failed"
        case .unknownError:
            return "mailgun.unknown_error"
        }
    }
    
    /// Reason
    public var reason: String {
        switch self {
        case .encodingProblem:
            return "Encoding problem"
        case .authenticationFailed:
            return "Failed authentication"
        case .unknownError(let err):
            return "Generic error - \(err)"
        }
    }
    
    
}

class Auth {
    
    static fileprivate var sharedInstance = Auth()
    
    var currentUser: User?
    var basicAuthorization: String?
    let resourceURL: URL
    static func auth() -> Auth {
        return sharedInstance
    }
    
    init() {
        guard let resourceURL = URL(string: Auth.baseURL) else {
            fatalError()
        }
        
        self.resourceURL = resourceURL
    }
    
    static let baseURL = "https://djmckay-tech-bespin.herokuapp.com/api/users/"
    
    func checkUser() -> Bool {
        if let loggedInUser = UserDefaultsManager.loggedInUser {
            self.currentUser = loggedInUser
        }
        if let authorization = UserDefaultsManager.basicAuthorization {
            self.basicAuthorization = authorization
        }
        return self.currentUser != nil && self.basicAuthorization != nil
    }
    
    func signIn(withEmail: String, password: String, completionHandler: @escaping (AuthRequestResult) -> ()) {
            let url = resourceURL.appendingPathComponent("login")
            var urlRequest = URLRequest(url: url)
            let credentials = "\(withEmail.lowercased()):\(password)"
            let encoded = Data(credentials.utf8).base64EncodedString()
            self.basicAuthorization = encoded
            urlRequest.addValue("Basic \(encoded)", forHTTPHeaderField: "Authorization")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpMethod = "GET"
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                guard let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 401 {
                                completionHandler(.failure(.authenticationFailed))
                            }
                        }
                        completionHandler(.failure(.unknownError("Invalid status code")))
                        return
                }
            
                guard let jsonData = data else {
                        completionHandler(.failure(.encodingProblem))
                        return
                }
                
                do {
                    let resource = try JSONDecoder().decode(User.self, from: jsonData)
                    self.currentUser = resource
                    UserDefaultsManager.loggedInUser = self.currentUser
                    UserDefaultsManager.basicAuthorization = self.basicAuthorization
                    completionHandler(.success(resource))
                } catch {
                    completionHandler(.failure(.encodingProblem))
                }
            }
            dataTask.resume()
        
    }
    
    func createUser(withEmail: String, password: String, completionHandler: (User?, Error?) -> ()) {
        completionHandler(nil, nil)
    }
    
    func signOut() {
        UserDefaultsManager.isLoggedIn = false
        UserDefaultsManager.loggedInUser = nil
        UserDefaultsManager.basicAuthorization = nil
    }
    
    func sendPasswordReset(withEmail: String, completionHandler: (Error?) -> ()) {
        
    }
    
    func newPassword(user: User, password: String, complete: @escaping ((_ status: Bool, _ error: Error?) -> ())) {
        let credentials = "\(user.username.lowercased()):\(password)"
        let encoded = Data(credentials.utf8).base64EncodedString()
        self.basicAuthorization = encoded
        self.currentUser = user
    }
}
