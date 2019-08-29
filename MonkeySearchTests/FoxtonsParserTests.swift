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

        XCTAssertEqual(result.count, 64)

        XCTAssertEqual(result.first?.agency, "Foxtons")
        XCTAssertEqual(result.first?.detailURL, URL(string: "https://www.foxtons.co.uk/properties-to-rent/n3/chpk3655265"))
        XCTAssertEqual(result.first?.id, "property_1110390")
        XCTAssertEqual(result.first?.name, "Mountfield Road, Finchley, N3")
        XCTAssertEqual(result.first?.price, "£484.62")
        XCTAssertEqual(result.first?.status, "New")
        XCTAssertEqual(result.first?.text,
            "Set on the ground floor this outstanding 2 bed boasts a stunning kitchen/reception room with bi-fold doors, electric blinds, remote lighting, a Private Garden, 2 generous bedrooms and a modern bathroom.  View more."
        )
    }
}
