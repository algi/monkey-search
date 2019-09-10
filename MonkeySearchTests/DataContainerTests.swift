//
//  DataContainerTests.swift
//  MonkeySearchTests
//
//  Created by Marian Bouček on 09/09/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import Foundation
import CoreData
import XCTest

@testable import MonkeySearch

class DataContainerTests: XCTestCase {

    var container: NSPersistentContainer!

    override func setUp() {
        guard container == nil else {
            return
        }

        let container = NSPersistentContainer(name: "MonkeySearch")
        container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")

        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Unexpected error: \(error.localizedDescription)")
            }
        }

        self.container = container
    }

    override func tearDown() {
        guard let container = container else { fatalError("Unable to find persistent container.") }

        container.viewContext.reset()
    }

    func testFetchData() throws {
        insertFakeData()

        var fetchedData: [EstateRecord]? = nil
        let subject = DataContainer(container: container)

        self.measure {
            do {
                fetchedData = try subject.fetchData()
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }

        let result = try XCTUnwrap(fetchedData)
        XCTAssertEqual(result.count, 1000)
    }

    func testPersistDifferenceBetween() throws {

        let existingEstate = Estate(context: container.viewContext)
        existingEstate.externalID = "1"
        existingEstate.date = Date()

        let newData = [
            record(id: "1"),
            record(id: "2"),
            record(id: "3")
        ]

        let subject = DataContainer(container: container)
        var result: [EstateRecord]!

        self.measure {
            container.viewContext.reset()

            do {
                result = try subject.merge(newData: newData)
            }
            catch {
                XCTFail(error.localizedDescription)
            }
        }

        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result.first?.id, "3")
        XCTAssertEqual(result.last?.id, "1")
    }

    private func record(id: String) -> EstateRecord {
        return EstateRecord(agency: "Foxtons",
                            date: Date(),
                            detailURL: URL(string: "https://www.apple.com")!,
                            id: id,
                            name: "Property",
                            price: "0",
                            status: "New",
                            text: "")
    }

    private func insertFakeData() {
        let context = container.viewContext

        for _ in 1...1000 {
            let estate = Estate(context: context)
            estate.status = "New"
        }

        for _ in 1...1000 {
            let estate = Estate(context: context)
            estate.status = "Hidden"
        }
    }
}
