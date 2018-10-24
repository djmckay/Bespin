//
//  BespinModel.swift
//  App
//
//  Created by DJ McKay on 10/19/18.
//

import Foundation
import Vapor
import FluentMySQL

protocol BespinModel: MySQLUUIDModel {
    
    associatedtype Public
    func convertToPublic() -> Public
    
    //    static var createdAtKey: TimestampKey? { get }
    //    static var updatedAtKey: TimestampKey? { get }
    //    var createdAt: Date? { get set }
    //    var updatedAt: Date? { get set }
}



protocol BespinUserTrackable: BespinModel {
    
    static var createdAtKey: TimestampKey? { get }
    static var updatedAtKey: TimestampKey? { get }
    var createdAt: Date? { get set }
    var updatedAt: Date? { get set }
}
