//
//  DataProviderTests.swift
//  MonkeySearchTests
//
//  Created by Marian Bouček on 10/09/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import XCTest

@testable import MonkeySearch

class DataProviderTests: XCTestCase {

    func testRefreshDataWithEmptyContext() {
        guard let dextersURL = Bundle(for: DataProviderTests.self).url(forResource: "dexters", withExtension: "html") else {
            fatalError("Unable to find dexters.html file.")
        }

        let config = Configuration(agencies: [
            Agency(name: "Dexters", filters: [
                dextersURL
            ])
        ])

        let persistentContainer = InMemoryPersistentContainer()

        let container = DataContainer(container: persistentContainer)
        let provider = DataProvider(container: container)

        provider.refreshData(using: config)

        let recordsExpectation = self.expectation(description: "EstateRecords")
        let _ = provider.$data.subscribe(on: RunLoop.main)
            .dropFirst() // first call is initial data
            .sink { (records) in
                XCTAssertEqual(records.count, 4)

                XCTAssertEqual(records[0].id, "124872")
                XCTAssertEqual(records[1].id, "123709")
                XCTAssertEqual(records[2].id, "123862")
                XCTAssertEqual(records[3].id, "124079")

                recordsExpectation.fulfill()
            }

        wait(for: [recordsExpectation], timeout: 2)
    }

    func testRefreshDataWithPredefinedContext() {
        guard let dextersURL = Bundle(for: DataProviderTests.self).url(forResource: "dexters", withExtension: "html") else {
            fatalError("Unable to find dexters.html file.")
        }

        let config = Configuration(agencies: [
            Agency(name: "Dexters", filters: [
                dextersURL
            ])
        ])

        let persistentContainer = InMemoryPersistentContainer()

        let entity = Estate(context: persistentContainer.viewContext)
        entity.externalID = "123709"
        entity.status = "Hidden" // do NOT include me in results

        let container = DataContainer(container: persistentContainer)
        let provider = DataProvider(container: container)

        provider.refreshData(using: config)

        let recordsExpectation = self.expectation(description: "EstateRecords")
        let _ = provider.$data.subscribe(on: RunLoop.main)
            .dropFirst() // first call is initial data
            .sink { (records) in
                XCTAssertEqual(records.count, 3)

                XCTAssertEqual(records[0].id, "124872")
                XCTAssertEqual(records[1].id, "123862")
                XCTAssertEqual(records[2].id, "124079")

                recordsExpectation.fulfill()
            }

        wait(for: [recordsExpectation], timeout: 2)
    }
}
