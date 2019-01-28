//
//  EmailAttachment.swift
//  App
//
//  Created by DJ McKay on 10/19/18.
//

import Foundation
import Vapor

public struct EmailAttachment: Content {
    
    
    /// Name of the file, including extension.
    public var filename: String
    
    /// The file's data.
    public var data: Data
    
    /// Associated `MediaType` for this file's extension, if it has one.
    public var contentType: MediaType? {
        return ext.flatMap { MediaType.fileExtension($0.lowercased()) }
    }
    
    /// The file extension, if it has one.
    public var ext: String? {
        return filename.split(separator: ".").last.map(String.init)
    }
    
    /// Creates a new `File`.
    ///
    ///     let file = File(data: "hello", filename: "foo.txt")
    ///
    /// - parameters:
    ///     - data: The file's contents.
    ///     - filename: The name of the file, not including path.
    public init(data: LosslessDataConvertible, filename: String) {
        self.data = data.convertToData()
        self.filename = filename
    }
    
//    /// The Base64 encoded content of the attachment.
//    public var content: String?
//    
//    /// The mime type of the content you are attaching. For example, “text/plain” or “text/html”.
//    public var type: String?
//    
//    /// The filename of the attachment.
//    public var filename: String?
//    
//    /// The content-disposition of the attachment specifying how you would like the attachment to be displayed.
//    public var disposition: String?
//    
//    /// The content id for the attachment. This is used when the disposition is set to “inline” and the attachment is an image, allowing the file to be displayed within the body of your email.
//    public var contentId: String?
//    
//    public init(content: String? = nil,
//                type: String? = nil,
//                filename: String? = nil,
//                disposition: String? = nil,
//                contentId: String? = nil) {
//        self.content = content
//        self.type = type
//        self.filename = filename
//        self.disposition = disposition
//        self.contentId = contentId
//    }
//    
//    public enum CodingKeys: String, CodingKey {
//        case content
//        case type
//        case filename
//        case disposition
//        case contentId = "content_id"
//    }
}
