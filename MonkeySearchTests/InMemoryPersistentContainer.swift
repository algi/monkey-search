//
//  InMemoryPersistentContainer.swift
//  MonkeySearchTests
//
//  Created by Marian Bouček on 10/09/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import CoreData

/// In-memory persistent container for CoreData.
class InMemoryPersistentContainer: NSPersistentContainer {

    convenience init() {
        self.init(name: "MonkeySearch")

        persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")

        loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Unexpected error: \(error.localizedDescription)")
            }
        }
    }
}
