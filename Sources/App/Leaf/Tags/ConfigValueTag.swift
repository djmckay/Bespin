//
//  ConfigValueTag.swift
//  App
//
//  Created by DJ McKay on 10/19/18.
//

import Leaf

public final class HtmlizeTag: TagRenderer {
    /// Creates a new `Print` tag renderer.
    public init() { }
    
    /// See `TagRenderer`.
    public func render(tag: TagContext) throws -> Future<TemplateData> {
        try tag.requireNoBody()
        try tag.requireParameterCount(1)
        let string = tag.parameters[0].string ?? ""
        return Future.map(on: tag) { .string(string.htmlize()) }
    }
}

extension String {
    /// Escapes HTML entities in a `String`.
    internal func htmlEscaped() -> String {
        /// FIXME: performance
        return replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
    
    internal func htmlize() -> String {
        /// FIXME: performance
        return replacingOccurrences(of: "\n", with: "<br>").htmlEscaped()
    }
}
