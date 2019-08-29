//
//  FoxtonsParserTests.swift
//  MonkeySearchTests
//
//  Created by Marian Bouček on 29/08/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import XCTest
@testable import MonkeySearch

class FoxtonsParserTests: XCTestCase {

    func testParseSimpleFile() throws {

        guard let fileURL = Bundle(for: FoxtonsParserTests.self).url(forResource: "foxtons", withExtension: "html") else {
            XCTFail("Unable to find file: 'foxtons.html'")
            return
        }

        let html = try String(contentsOf: fileURL)

        let parser = FoxtonsParser()
        var result = [EstateRecord]()

        self.measure {
            do {
                result = try parser.parse(html)
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }

        XCTAssertEqual(result.count, 0)
    }
}
