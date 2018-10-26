//
//  MailgunProvider.swift
//  App
//
//  Created by DJ McKay on 10/19/18.
//

import Vapor

public struct MailgunConfig: Service {
    let apiKey: String
    let domain: String
    public init(apiKey: String, domain: String) {
        self.apiKey = apiKey
        self.domain = domain
    }
}

public final class MailgunProvider: Provider {
    public static let repositoryName = "mailgun-provider"
    
    public init(){}
    
    public func boot(_ config: Config) throws {}
    
    public func didBoot(_ worker: Container) throws -> EventLoopFuture<Void> {
        return .done(on: worker)
    }
    
    public func register(_ services: inout Services) throws {
        services.register { (container) -> MailgunClient in
            let httpClient = try container.make(Client.self)
            let logger = try container.make(Logger.self)
//            let config = try container.make(MailgunConfig.self)
//            return MailgunClient(client: httpClient, apiKey: config.apiKey, domain: config.domain)
            return MailgunClient(client: httpClient, logger: logger)
        }
    }
}
