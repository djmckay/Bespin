//
//  TokenRequest.swift
//  BespinApp
//
//  Created by DJ McKay on 11/26/18.
//

import Foundation

enum MessageResult<ResourceType> {
    case success(ResourceType)
    case failure(BespinRequestError)
}

public enum BespinRequestError {
    
    /// Encoding problem
    case encodingProblem
    
    /// Failed authentication
    case authenticationFailed
    
    /// Failed to send email (with error message)
    case unableToSendEmail
    
    /// Generic error
    case unknownError(String)
    
    /// Identifier
    public var identifier: String {
        switch self {
        case .encodingProblem:
            return "bespin.encoding_error"
        case .authenticationFailed:
            return "bespin.auth_failed"
        case .unableToSendEmail:
            return "bespin.send_email_failed"
        case .unknownError:
            return "bespin.unknown_error"
        }
    }
    
    /// Reason
    public var reason: String {
        switch self {
        case .encodingProblem:
            return "Encoding problem"
        case .authenticationFailed:
            return "Failed authentication"
        case .unableToSendEmail:
            return "Failed to send email"
        case .unknownError(let reason):
            return "Generic error - \(reason)"
        }
    }
}

struct TokenRequest {
    let resource: URL
    var token: Token!
    
    init(token: Token) {
        let resourceString = "https://bespin-mail-api.vapor.cloud/api/\(token.id!.uuidString)"
        guard let resourceURL = URL(string: resourceString) else {
            fatalError()
        }
        self.token = token
        self.resource = resourceURL
    }
    
    func getTemplates(completion: @escaping (GetResourcesRequest<Template>) -> Void) {
        let url = resource.appendingPathComponent("templates")
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(getJWT())", forHTTPHeaderField: "Authorization")
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    completion(.failure)
                    return
            }
            guard let jsonData = data else {
                completion(.failure)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let templates = try decoder.decode([Template].self, from: jsonData)
                completion(.success(templates))
            } catch {
                completion(.failure)
            }
        }
        dataTask.resume()
    }
    
    func saveTemplate(template: Template, completion: @escaping (SaveResult<Template>) -> Void) {
        do {
        var path = "templates"
            if let id = template.id?.uuidString {
                path = path.appending("/\(id)")
            }
        let url = resource.appendingPathComponent(path)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
            if template.id != nil {
                urlRequest.httpMethod = "PUT"
            }
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(getJWT())", forHTTPHeaderField: "Authorization")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        urlRequest.httpBody = try encoder.encode(template)
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    completion(.failure)
                    return
            }
            guard let jsonData = data else {
                completion(.failure)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let template = try decoder.decode(Template.self, from: jsonData)
                completion(.success(template))
            } catch {
                completion(.failure)
            }
        }
        dataTask.resume()
        } catch {
            completion(.failure)
        }
    }
    
    func deleteTemplate(template: Template, completion: @escaping (DeleteResult<Template>) -> Void) {
        guard let id = template.id else {
            completion(.failure)
            return
        }
        
            let url = resource.appendingPathComponent("templates/\(id.uuidString)")
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "DELETE"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue("Bearer \(getJWT())", forHTTPHeaderField: "Authorization")
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
                guard let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 204 else {
                        completion(.failure)
                        return
                }
                guard data != nil else {
                    completion(.failure)
                    return
                }
                
                
                completion(.success)
                
            }
            dataTask.resume()
        
    }
    
    func getTemplate(templateId: UUID, completion: @escaping (GetResourceRequest<Template>) -> Void) {
        
            let url = resource.appendingPathComponent("templates/\(templateId.uuidString)")
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue("Bearer \(getJWT())", forHTTPHeaderField: "Authorization")
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
                guard let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        completion(.failure)
                        return
                }
                guard let jsonData = data else {
                    completion(.failure)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let template = try decoder.decode(Template.self, from: jsonData)
                    completion(.success(template))
                } catch {
                    completion(.failure)
                }
            }
            dataTask.resume()
        
    }
    
    func message(message: Message, completion: @escaping (MessageResult<Message.MessageResponse>) -> Void) {
        do {
            let path = "messages"
            let url = resource.appendingPathComponent(path)
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue("Bearer \(getJWT())", forHTTPHeaderField: "Authorization")
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            urlRequest.httpBody = try encoder.encode(message)
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
                guard let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 401 {
                                completion(.failure(.authenticationFailed))
                                return
                            } else {
                                completion(.failure(.unknownError("Status Code: \(httpResponse.statusCode)")))
                                return
                            }
                        }
                        completion(.failure(.unknownError("Invalid Response")))
                        return
                }
                guard let jsonData = data else {
                    completion(.failure(.encodingProblem))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(Message.MessageResponse.self, from: jsonData)
                    completion(.success(response))
                } catch {
                    completion(.failure(.encodingProblem))
                }
            }
            dataTask.resume()
        } catch {
            completion(.failure(.unknownError(error.localizedDescription)))
        }
    }
    
    private func getJWT() -> String {
        var claims = ClaimSet()
        claims["key"] = token.id?.uuidString
        claims["name"] = DataManager.sharedInstance.currentUser?.name
        claims["domain"] = DataManager.sharedInstance.currentUser?.domain
        return JWT.encode(claims: claims, algorithm: .hs256(token.token.data(using: .utf8)!))
    }
    
    func saveTemplateAttachment(attachment: Template.Attachment, completion: @escaping (SaveResult<Template.Attachment>) -> Void) {
        do {
            var path = "templates/\(attachment.templateID.uuidString)/attachments"
            let url = resource.appendingPathComponent(path)
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            if let id = attachment.id?.uuidString {
                path = path.appending("/\(id)")
                urlRequest.httpMethod = "PUT"
            }
            
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue("Bearer \(getJWT())", forHTTPHeaderField: "Authorization")
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            urlRequest.httpBody = try encoder.encode(attachment)
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
                guard let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        completion(.failure)
                        return
                }
                guard let jsonData = data else {
                    completion(.failure)
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let attachment = try decoder.decode(Template.Attachment.self, from: jsonData)
                    completion(.success(attachment))
                } catch {
                    completion(.failure)
                }
            }
            dataTask.resume()
        } catch {
            completion(.failure)
        }
    }
    
    func getTemplateAttachments(template: Template, completion: @escaping (GetResourcesRequest<Template.Attachment>) -> Void) {
        guard let templateID = template.id else { completion(.failure); return }
        var path = "templates/\(templateID.uuidString)/attachments"
        let url = resource.appendingPathComponent(path)
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(getJWT())", forHTTPHeaderField: "Authorization")
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    completion(.failure)
                    return
            }
            guard let jsonData = data else {
                completion(.failure)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let templates = try decoder.decode([Template.Attachment].self, from: jsonData)
                completion(.success(templates))
            } catch {
                completion(.failure)
            }
        }
        dataTask.resume()
    }
    
    func deleteTemplateAttachment(attachment: Template.Attachment, completion: @escaping (DeleteResult<Template.Attachment>) -> Void) {
        guard attachment.id != nil else {
            completion(.failure)
            return
        }
        var path = "templates/\(attachment.templateID.uuidString)/attachments/\(attachment.id!.uuidString)"
        let url = resource.appendingPathComponent(path)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(getJWT())", forHTTPHeaderField: "Authorization")
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 204 else {
                    completion(.failure)
                    return
            }
            guard data != nil else {
                completion(.failure)
                return
            }
            
            
            completion(.success)
        }
        dataTask.resume()
    }
}


