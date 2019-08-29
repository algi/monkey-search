//
//  DextersParserTests.swift
//  MonkeySearchTests
//
//  Created by Marian Bouček on 29/08/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import XCTest
@testable import MonkeySearch

class DextersParserTests: XCTestCase {

    func testParseSimpleFile() throws {

        guard let fileURL = Bundle(for: FoxtonsParserTests.self).url(forResource: "dexters", withExtension: "html") else {
            XCTFail("Unable to find file: 'foxtons.html'")
            return
        }

        let html = try String(contentsOf: fileURL)

        let parser = DextersParser()
        var result = [EstateRecord]()

        self.measure {
            do {
                result = try parser.parse(html)
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }

        XCTAssertEqual(result.count, 4)

        XCTAssertEqual(result.first?.agency, "Dexters")
        XCTAssertEqual(result.first?.detailURL, URL(string: "https://www.dexters.co.uk/property-for-rent/flat-to-rent-in-fortis-green-road-london-n10/124872"))
        XCTAssertEqual(result.first?.id, "124872")
        XCTAssertEqual(result.first?.name, "Fortis Green RoadMuswell hill, N10")
        XCTAssertEqual(result.first?.price, "£2000 pcm")
        XCTAssertEqual(result.first?.status, "New")
        XCTAssertEqual(result.first?.text, "A modern three bedroom ground floor apartment with shared garden Close to Muswell Hill Broadway. The property features two double bedrooms, one single bedroom, a modern kitchen, modern shower room and plenty of storage. Available late October.")
    }
}
