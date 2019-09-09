//
//  DataProviderTests.swift
//  MonkeySearchTests
//
//  Created by Marian Bouček on 08/09/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import CoreData
import XCTest

@testable import MonkeySearch

class DataProviderTests: XCTestCase {

    var container: NSPersistentContainer? = nil

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

    func testFetchData() {
        guard let container = container else { fatalError("Unable to find persistent container.") }

        let context = container.viewContext

        for _ in 1...1000 {
            let estate = Estate(context: context)
            estate.status = "New"
        }

        for _ in 1...1000 {
            let estate = Estate(context: context)
            estate.status = "Hidden"
        }

        var provider: DataProvider? = nil
        self.measure {
            provider = DataProvider(container: container)
        }

        XCTAssertEqual(provider?.data.count, 1000)
    }

    func testPersistDownloadedData() throws {
        guard let container = container else { fatalError("Managed context is nil.") }

        let newData = [
            record(id: "1"),
            record(id: "2"),
            record(id: "3")
        ]

        let existingData = [
            record(id: "1")
        ]

        try persistDifferenceBetween(newData: newData, oldData: existingData, into: container)

        let request: NSFetchRequest<Estate> = Estate.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Estate.externalID, ascending: true)]

        let result = try container.viewContext.fetch(request)

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.externalID, "2")
        XCTAssertEqual(result.last?.externalID, "3")
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
}
