//
//  DataProcessor.swift
//  MonkeySearch
//
//  Created by Marian Bouček on 03/09/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import Combine
import CoreData

func fetchNewData() -> AnyPublisher<[EstateRecord], Error> {

    // TODO: finish the implementation
    /*
     1. načti data z internetu
     2. načtu existující záznamy, které nejsou skryté a transformuj je na ‹EstateRecord›
     3. ulož nové záznamy do CoreData (porovnej internetové s existujícími z CoreData)
     4. seřaď staré a nové záznamy dle data (od nejmladšího)
     */

    // TODO: support multiple agencies
    guard let agency = try? Configuration.defaultConfiguration().agencies.first else {
        fatalError()
    }

    guard let url = agency.filters.first else {
        fatalError()
    }

    return downloadData(from: url)
        .tryMap { (html) in try FoxtonsParser().parse(html) }
        .eraseToAnyPublisher()
}

/// Downloads data from specified URL. It may fail either because of network error, or during reading downloaded data.
/// - Parameter URL: Estate agency's fetch URL
func downloadData(from URL: URL) -> Future<String, Error> {
    return Future { (promise) in
        let task = URLSession.shared.downloadTask(with: URL) { (location, response, networkError) in
            if let networkError = networkError {
                promise(.failure(networkError))
                return
            }

            guard let location = location else {
                fatalError("Unable to find location of stored data, no error has been provided.")
            }

            do {
                let result = try String(contentsOf: location)
                promise(.success(result))
            }
            catch {
                promise(.failure(error))
            }
        }
        task.resume()
    }
}

/// Persists newly fetched data. Does not override existing data.
/// - Parameter newData: newly fetched data from network
/// - Parameter existingData: existing data, feched from CoreData storage
/// - Parameter viewContext: CoreData's view context
func persist(newData: [EstateRecord], existingData: [EstateRecord], into viewContext: NSManagedObjectContext) throws {
    let difference = newData.difference(from: existingData)

    for item in difference {
        switch item {
            case .insert(_, let record, _):
                _ = Estate(record: record, context: viewContext)
            default:
                break
        }
    }
}

/// Merges old and new data together. Then it sorts them by date.
/// - Parameter oldData: existing data (from CoreData storage)
/// - Parameter newData: new data (from network)
func merge(oldData: [EstateRecord], with newData: [EstateRecord]) -> [EstateRecord] {

    var result = [EstateRecord]()

    result.append(contentsOf: oldData)
    result.append(contentsOf: newData)

    return result.sorted { (first, second) in
        return first.date > second.date
    }
}

extension EstateRecord: Equatable {
    static func == (lhs: EstateRecord, rhs: EstateRecord) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Estate {
    convenience init(record: EstateRecord, context: NSManagedObjectContext) {
        self.init(context: context)

        self.agency = record.agency
        self.detailURL = record.detailURL
        self.date = record.date
        self.externalID = record.id
        self.name = record.name
        self.price = Int16(record.price) ?? 0
        self.status = record.status
        self.text = record.text
    }
}

extension EstateRecord {

    init(entity: Estate) {
        self.agency = entity.agency ?? "Unknown"
        self.detailURL = entity.detailURL ?? URL(string: "http://www.apple.com")!
        self.date = entity.date ?? Date()
        self.id = entity.externalID ?? "-1"
        self.name = entity.name ?? "No address"
        self.price = "\(entity.price)"
        self.status = entity.status ?? "New"
        self.text = entity.text ?? "No description"
    }
}
