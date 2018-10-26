//
//  Bespin.swift
//  App
//
//  Created by DJ McKay on 10/20/18.
//

import Foundation
import Vapor
import FluentMySQL

struct Bespin {
    static fileprivate let DatabaseUsername: String = Environment.get("DATABASE_USER") ?? "bespin"
    static fileprivate let DatabasePassword: String = Environment.get("DATABASE_PASSWORD") ?? "password"
    
    static let BespinConfig = MySQLDatabaseConfig(hostname: Environment.get("DATABASE_HOSTNAME") ?? "localhost", port: 3306, username: DatabaseUsername, password: DatabasePassword, database: Environment.get("DATABASE_DB") ?? "bespin")
    static let Bespin = MySQLDatabase(config: BespinConfig)
    
    static let BespinConfigTest = MySQLDatabaseConfig(hostname: Environment.get("DATABASE_HOSTNAME") ?? "localhost", port: 3307, username: DatabaseUsername, password: DatabasePassword, database: Environment.get("DATABASE_DB") ?? "bespin-test")
    static let BespinTest = MySQLDatabase(config: BespinConfigTest)
}

extension DatabaseIdentifier {
    /// Default identifier for `MySQLDatabase`.
    public static var Bespin: DatabaseIdentifier<MySQLDatabase> {
        return .init("Bespin")
    }
}

/// Captures all errors and transforms them into an internal server error HTTP response.
public final class BespinErrorMiddleware: Middleware, ServiceType {
    /// See `ServiceType`.
    public static func makeService(for worker: Container) throws -> BespinErrorMiddleware {
        return try .default(environment: worker.environment, log: worker.make())
    }
    
    /// Create a default `ErrorMiddleware`. Logs errors to a `Logger` based on `Environment`
    /// and converts `Error` to `Response` based on conformance to `AbortError` and `Debuggable`.
    ///
    /// - parameters:
    ///     - environment: The environment to respect when presenting errors.
    ///     - log: Log destination.
    public static func `default`(environment: Environment, log: Logger) -> BespinErrorMiddleware {
        /// Structure of `ErrorMiddleware` default response.
        struct ErrorResponse: Encodable {
            /// Always `true` to indicate this is a non-typical JSON response.
            var error: Bool
            
            /// The reason for the error.
            var reason: String
        }
        
        return .init { req, error in
            // log the error
            log.report(error: error, verbose: !environment.isRelease)
            
            // variables to determine
            let status: HTTPResponseStatus
            let reason: String
            let headers: HTTPHeaders
            
            // inspect the error type
            switch error {
            case let abort as AbortError:
                // this is an abort error, we should use its status, reason, and headers
                reason = abort.reason
                status = abort.status
                headers = abort.headers
            case let validation as ValidationError:
                // this is a validation error
                reason = validation.reason
                status = .badRequest
                headers = [:]
            case let debuggable as Debuggable where !environment.isRelease:
                // if not release mode, and error is debuggable, provide debug
                // info directly to the developer
                reason = debuggable.reason
                status = .internalServerError
                headers = [:]
            default:
                // not an abort error, and not debuggable or in dev mode
                // just deliver a generic 500 to avoid exposing any sensitive error info
                reason = "Something went wrong."
                status = .internalServerError
                headers = [:]
            }
            
            // create a Response with appropriate status
            let res = req.makeResponse(http: .init(status: status, headers: headers))
            
            // attempt to serialize the error to json
            do {
                let errorResponse = ErrorResponse(error: true, reason: reason)
                res.http.body = try HTTPBody(data: JSONEncoder().encode(errorResponse))
                res.http.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
            } catch {
                res.http.body = HTTPBody(string: "Oops: \(error)")
                res.http.headers.replaceOrAdd(name: .contentType, value: "text/plain; charset=utf-8")
            }
            return res
        }
    }
    
    /// Error-handling closure.
    private let closure: (Request, Error) -> (Response)
    
    /// Create a new `ErrorMiddleware`.
    ///
    /// - parameters:
    ///     - closure: Error-handling closure. Converts `Error` to `Response`.
    public init(_ closure: @escaping (Request, Error) -> (Response)) {
        self.closure = closure
    }
    
    /// See `Middleware`.
    public func respond(to req: Request, chainingTo next: Responder) throws -> Future<Response> {
        let response: Future<Response>
        do {
            response = try next.respond(to: req)
        } catch {
            response = req.eventLoop.newFailedFuture(error: error)
        }
        
        return response.mapIfError { error in
            return self.closure(req, error)
        }
    }
}





