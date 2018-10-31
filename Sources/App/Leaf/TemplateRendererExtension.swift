//
//  TemplateRendererExtension.swift
//  App
//
//  Created by DJ McKay on 10/27/18.
//

import Leaf

extension TemplateRenderer {
    func renderString<E>(_ template: String, context: E) throws -> Future<View> where E: Encodable {
        return self.render(template: template.data(using: .utf8)!, context)
            
        //return String(data: view.data, encoding: .utf8)!
    }
}

extension TemplateRenderer {
    func testRender(_ template: String, _ context: TemplateData = .null) throws -> Future<View> {
        let view = self.render(template: template.data(using: .utf8)!, context)
        return view
    }
}

extension TemplateDataEncoder {
    func testEncode<E>(_ encodable: E) throws -> Future<TemplateData> where E: Encodable {
        return try encode(encodable, on: EmbeddedEventLoop())
    }
}


