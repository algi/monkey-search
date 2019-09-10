//
//  DataContainerTests.swift
//  MonkeySearchTests
//
//  Created by Marian Bouček on 09/09/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import CoreData
import XCTest

@testable import MonkeySearch

class DataContainerTests: XCTestCase {

    func testFetchData() throws {

        let container = InMemoryPersistentContainer()
        insertFakeData(into: container)

        let result: [EstateRecord]
        do {
            result = try DataContainer(container: container).fetchData()
        }
        catch {
            XCTFail(error.localizedDescription)
            return
        }

        XCTAssertEqual(result.count, 1000)
    }

    func testMergeWithHiddenData() throws {

        let container = InMemoryPersistentContainer()

        let existingEstate = Estate(context: container.viewContext)
        existingEstate.externalID = "1"
        existingEstate.status = "Hidden"
        existingEstate.date = Date()

        let newData = [
            record(id: "1"),
            record(id: "2"),
            record(id: "3")
        ]

        // merge new and old data
        let result: [EstateRecord]
        do {
            result = try DataContainer(container: container).merge(newData: newData)
        }
        catch {
            XCTFail(error.localizedDescription)
            return
        }

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.id, "2")
        XCTAssertEqual(result.last?.id, "3")

        // verify saved data
        let request: NSFetchRequest<Estate> = Estate.fetchRequest()
        let savedData = try container.viewContext.fetch(request)

        XCTAssertEqual(savedData.count, 3)
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

    private func insertFakeData(into container: NSPersistentContainer) {
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
