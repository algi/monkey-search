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
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Estate.date, ascending: true)]

        let savedData = try container.viewContext.fetch(request)
        XCTAssertEqual(savedData.count, 3)

        let last = try XCTUnwrap(savedData.last)

        XCTAssertEqual(last.agency, "Foxtons")
        XCTAssertEqual(last.detailURL, URL(string: "https://www.apple.com"))
        XCTAssertEqual(last.externalID, "3")
        XCTAssertEqual(last.name, "Property")
        XCTAssertEqual(last.price, 400)
        XCTAssertEqual(last.status, "New")
        XCTAssertEqual(last.text, "Description")
        XCTAssertEqual(last.previewImageURL, URL(string: "https://www.apple.com"))
    }

    func testMarkAsHidden() throws {

        let container = InMemoryPersistentContainer()

        let firstEstate = Estate(context: container.viewContext)
        firstEstate.externalID = "1"
        firstEstate.status = RecordStatus.new.string()
        firstEstate.date = Date()

        let secondEstate = Estate(context: container.viewContext)
        secondEstate.externalID = "2"
        secondEstate.status = RecordStatus.new.string()
        secondEstate.date = Date()

        let hiddenRecords = [
            record(id: "1")
        ]

        try DataContainer(container: container).markAsHidden(records: hiddenRecords)

        XCTAssertEqual(firstEstate.status, RecordStatus.hidden.string())
        XCTAssertEqual(secondEstate.status, RecordStatus.new.string())
    }

    private func record(id: String) -> EstateRecord {
        return EstateRecord(agency: "Foxtons",
                            date: Date(),
                            detailURL: URL(string: "https://www.apple.com")!,
                            id: id,
                            name: "Property",
                            price: 400,
                            status: .new,
                            text: "Description",
                            previewImageURL: URL(string: "https://www.apple.com")!)
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
