//
//  ConfigurationTests.swift
//  MonkeySearchTests
//
//  Created by Marian Bouček on 08/09/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import XCTest
@testable import MonkeySearch

class ConfigurationTests: XCTestCase {

    func testDefaultConfiguration() throws {
        let config = try Configuration.defaultConfiguration()

        XCTAssertEqual(config.agencies.count, 1)

        let agency = config.agencies.first

        XCTAssertEqual(agency?.name, "Dexters")
        XCTAssertEqual(agency?.filters.first, URL(string: "https://www.dexters.co.uk/property-lettings/2-bedroom-properties-available-to-rent-in-muswell-hill-between-1500-and-2200"))
    }
}
