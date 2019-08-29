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

        let parser = FoxtonsParser()
        var result = [EstateRecord]()

        self.measure {
            do {
                result = try parser.parse(
                    """
                    <html>
                        <body>
                            <h6>Test</h6>
                        </body>
                    </html>
                    """)
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }

        XCTAssertEqual(result.count, 0)
    }
}
