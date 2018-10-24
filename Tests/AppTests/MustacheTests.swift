//
//  MustacheTests.swift
//  AppTests
//
//  Created by DJ McKay on 10/24/18.
//

@testable import App
import Vapor
import XCTest

class MustacheTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBasicExample() throws {
        // Load the `document.mustache` resource of the main bundle
        let realDate = Date().addingTimeInterval(60*60*24*3)
        let date = Date()
        let template = try Template(string: "Hello {{name}} {{format(date)}} {{format(realDate)}}")
        
        // Let template format dates with `{{format(...)}}`
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        template.register(dateFormatter, forKey: "format")
        
        // The rendered data
        let data: [String: Any] = [
            "name": "Arthur",
            "date": date,
            "realDate": realDate,
            "late": true
        ]
        
        // The rendering: "Hello Arthur..."
        do {
            let rendering = try template.render(data)
            let expectedRender = "Hello Arthur \(dateFormatter.string(from: date)) \(dateFormatter.string(from: realDate))"
            
            XCTAssertEqual(rendering, expectedRender)
        } catch {
            XCTFail()
        }
        
        
    }
    
    func testNestedExample() throws {
        // Load the `document.mustache` resource of the main bundle
        let realDate = Date().addingTimeInterval(60*60*24*3)
        let date = Date()
        let template = try Template(string: "Hello {{name}} {{format(date)}} {{format(realDate)}}.  There are {{items.count}} item(s): {{#items}}{{name}} {{/items}}")
        
        // Let template format dates with `{{format(...)}}`
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        template.register(dateFormatter, forKey: "format")
        
        // The rendered data
        let data: [String: Codable] = [
            "name": "Mustache",
            "date": date,
            "realDate": realDate,
            "late": "true",
            "items": [["name": "one"], ["name": "two"]]
        ]
        
        // The rendering: "Hello Arthur..."
        let itemArray = data["items"] as! [AnyObject]
        do {
            let rendering = try template.render(data)
            let expectedRender = "Hello Mustache \(dateFormatter.string(from: date)) \(dateFormatter.string(from: realDate)).  There are \(itemArray.count) item(s): one two "
            
            XCTAssertEqual(rendering, expectedRender)
        } catch {
            XCTFail()
        }
        
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
