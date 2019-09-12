//
//  None.swift
//  BespinApp
//
//  Created by DJ McKay on 11/26/18.
//

import Foundation


/// No Algorithm, i-e, insecure
public final class NoneAlgorithm: AlgorithmType, SignAlgorithm, VerifyAlgorithm {
    public var name: String {
        return "none"
    }
    
    public init() {}
    
    public func sign(_ message: Data) -> Data {
        return Data()
    }
}
