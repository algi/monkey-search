//
//  DataContainer.swift
//  MonkeySearch
//
//  Created by Marian Bouček on 09/09/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import CoreData

class DataContainer: NSObject {

    let container: NSPersistentContainer

    init(container: NSPersistentContainer) {
        self.container = container
    }

    /// Fetches existing data from CoreData storage.
    func fetchData(filterHidden: Bool = true) throws -> [EstateRecord] {
        let request: NSFetchRequest<Estate> = Estate.fetchRequest()

        if filterHidden {
            request.predicate = NSPredicate(format: "status != %@", "Hidden")
        }

        request.sortDescriptors = [NSSortDescriptor(keyPath: \Estate.date, ascending: true)]

        let result = try container.viewContext.fetch(request)
        return result.map { (entity) in EstateRecord(entity: entity) }
    }

    /// Merges new data into existing context. Returns merged data, which is sorted by date.
    /// - Parameter newData: newly fetched data from network
    func merge(newData: [EstateRecord]) throws -> [EstateRecord] {

        let oldData = try fetchData(filterHidden: false)

        for change in newData.difference(from: oldData) {
            if case .insert(_, let record, _) = change {
                _ = Estate(record: record, context: container.viewContext)
            }
        }

        try container.viewContext.save()

        return merge(oldData: oldData, with: newData)
    }

    /// Merges old and new data together. Then it sorts them by date.
    /// - Parameter oldData: existing data (from CoreData storage)
    /// - Parameter newData: new data (from network)
    private func merge(oldData: [EstateRecord], with newData: [EstateRecord]) -> [EstateRecord] {

        var result = [EstateRecord](oldData)

        for record in newData {
            if result.contains(record) {
                continue
            }

            result.append(record)
        }

        return result.filter { (record) in
            return record.status != .hidden
        }.sorted { (first, second) in
            return first.date < second.date
        }
    }

    /// Marks records as hidden.
    /// - Parameter records: records to be marked
    func markAsHidden(records: [EstateRecord]) throws {

        let listOfIDs = records.map { (record) in
            record.id
        }

        let request: NSFetchRequest<Estate> = Estate.fetchRequest()
        request.predicate = NSPredicate(format: "externalID IN %@", listOfIDs)

        let result = try container.viewContext.fetch(request)

        for entity in result {
            entity.status = RecordStatus.hidden.string()
        }

        try container.viewContext.save()
    }
}
