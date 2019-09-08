//
//  DataProvider.swift
//  MonkeySearch
//
//  Created by Marian Bouček on 08/09/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import CoreData

class DataProvider: ObservableObject {

    @Published var data: [EstateRecord]

    private let container: NSPersistentContainer?

    init(data: [EstateRecord]) {
        self.data = data
        self.container = nil
    }

    init(container: NSPersistentContainer) {
        self.container = container
        self.data = fetchData(from: container)
    }

    func refreshData() {

        guard let container = container else {
            return
        }

        // TODO: load new data from the internet and merge them with existing data
        self.data = fetchData(from: container)
    }
}

private func fetchData(from container: NSPersistentContainer) -> [EstateRecord] {
    let request: NSFetchRequest<Estate> = Estate.fetchRequest()

    request.predicate = NSPredicate(format: "status == %@", "New") // TODO: use Enum, if possible
    request.sortDescriptors = [NSSortDescriptor(keyPath: \Estate.date, ascending: true)]

    do {
        let result = try container.viewContext.fetch(request)
        return result.map { (entity) in EstateRecord(entity: entity) }
    }
    catch (let error as NSError) {
        print("Unable to fetch data from CoreData. Description: \(error.description), userInfo: \(error.userInfo)")
        return [EstateRecord]()
    }
}
