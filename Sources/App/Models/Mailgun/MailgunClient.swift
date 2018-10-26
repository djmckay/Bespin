//
//  MailgunClient.swift
//  App
//
//  Created by DJ McKay on 10/19/18.
//

import Vapor

public final class MailgunClient: Service {
    let httpClient: Client
//    let apiKey: String
    let apiEndpoint = "https://api.mailgun.net/v3/"
//    public let domain: String
    
//    public init(client: Client, apiKey: String, domain: String) {
//        self.httpClient = client
//        self.apiKey = apiKey
//        self.domain = domain
//    }
    var logger: Logger
    
    public init(client: Client, logger: Logger) {
        self.httpClient = client
        self.logger = logger
    }
    
    public func send(apiKey: String, domain: String, _ email: MailgunEmail, on worker: Worker) throws -> Future<Response> {
        let authKeyEncoded = try encode(apiKey: apiKey)
            var headers: HTTPHeaders = [:]
            headers.add(name: HTTPHeaderName.authorization, value: "Basic \(authKeyEncoded)")
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .secondsSince1970
            
            print(apiEndpoint+domain+"/messages")
            let request = httpClient.post(apiEndpoint+domain+"/messages", headers: headers) { req in
                let data = try encoder.encode(email)
                print(String(data: data, encoding: .utf8)!)
                try req.content.encode(email)
            }
            return request.map { response in
                return try self.process(response)
            }
    }
    
    public func send(apiKey: String, domain: String, _ emails: [MailgunEmail], on worker: Worker) throws -> Future<Void> {
        let authKeyEncoded = try encode(apiKey: apiKey)
        return emails.map { (email) in
            
            var headers: HTTPHeaders = [:]
            headers.add(name: HTTPHeaderName.authorization, value: "Basic \(authKeyEncoded)")
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .secondsSince1970
            
            print(apiEndpoint+domain+"/messages")
            let request = httpClient.post(apiEndpoint+domain+"/messages", headers: headers) { req in
                let data = try encoder.encode(email)
                print(String(data: data, encoding: .utf8)!)
                try req.content.encode(email)
            }
            return request.map { response in
                try self.process(response)
            }
            }.flatten(on: worker)
    }
    
//    public func setup(forwarding setup: RouteSetup, with container: Container) throws -> Future<Response> {
//        let authKeyEncoded = try encode(apiKey: self.apiKey)
//        
//        var headers = HTTPHeaders([])
//        headers.add(name: HTTPHeaderName.authorization, value: "Basic \(authKeyEncoded)")
//        
//        let mailgunURL = "https://api.mailgun.net/v3/routes"
//        
//        let client = try container.make(Client.self)
//        
//        return client.post(mailgunURL, headers: headers) { req in
//            try req.content.encode(setup)
//            }.map(to: Response.self) { (response) in
//                try self.process(response)
//        }
//    }
    
    fileprivate func encode(apiKey: String) throws -> String {
        guard let apiKeyData = "api:\(apiKey)".data(using: .utf8) else {
            throw Error.encodingProblem
        }
        let authKey = apiKeyData.base64EncodedData()
        guard let authKeyEncoded = String.init(data: authKey, encoding: .utf8) else {
            throw Error.encodingProblem
        }
        
        return authKeyEncoded
    }
    
    private func process(_ response: Response) throws -> Response {
        logger.verbose("[\(Date())] MailgunClient processing: \(response.http.status)")
        switch true {
        case response.http.status.code == HTTPStatus.ok.code:
            return response
        case response.http.status.code == HTTPStatus.unauthorized.code:
            throw Error.authenticationFailed
        default:
            if let data = response.http.body.data, let err = (try? JSONDecoder().decode(ErrorResponse.self, from: data)) {
                throw Error.unableToSendEmail(err)
            }
            throw Error.unknownError(response)
        }
    }
    
    public enum Error: Debuggable {
        
        /// Encoding problem
        case encodingProblem
        
        /// Failed authentication
        case authenticationFailed
        
        /// Failed to send email (with error message)
        case unableToSendEmail(ErrorResponse)
        
        /// Generic error
        case unknownError(Response)
        
        /// Identifier
        public var identifier: String {
            switch self {
            case .encodingProblem:
                return "mailgun.encoding_error"
            case .authenticationFailed:
                return "mailgun.auth_failed"
            case .unableToSendEmail:
                return "mailgun.send_email_failed"
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
            case .unableToSendEmail(let err):
                return "Failed to send email (\(err.message))"
            case .unknownError:
                return "Generic error"
            }
        }
    }
    
    /// Error response object
    public struct ErrorResponse: Decodable {
        
        /// Error messsage
        public let message: String
        
    }
    
    /// Mailgun response object
    public struct MailgunResponse: Content {
        
        /// messsage
        public let message: String
        public let id: String
    }
}
