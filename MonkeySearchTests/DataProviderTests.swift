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
}
