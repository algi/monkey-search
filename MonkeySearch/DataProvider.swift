//
//  DataProvider.swift
//  MonkeySearch
//
//  Created by Marian Bouček on 08/09/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import Combine
import CoreData

class DataProvider: ObservableObject {

    @Published var data: [EstateRecord]

    private let container: NSPersistentContainer?
    private var cancelable: AnyCancellable?

    init(data: [EstateRecord]) {
        self.data = data
        self.container = nil
    }

    init(container: NSPersistentContainer) {
        self.container = container

        do {
            self.data = try fetchData(from: container)
        }
        catch {
            // TODO: capture error
            print("Unable to fetch records, error: \(error.localizedDescription)")
            self.data = [EstateRecord]()
        }
    }

    /// Downloads new data from the internet and merges them with existing data.
    func refreshData() {
        guard let container = container else { return }

        let configuration: Configuration
        do {
            configuration = try Configuration.defaultConfiguration()
        }
        catch {
            fatalError("Unable to read configuration: \(error.localizedDescription)")
        }

        cancelable = downloadAndTransformData(using: configuration)
            .collect()
            .reduce([EstateRecord]()) { (initialResult, records) in
                return records.reduce(into: initialResult) { (result, records) in
                    result.append(contentsOf: records)
                }
            }
            .tryMap { newData in

                let oldData = try fetchData(from: container)
                try persistDifferenceBetween(newData: newData, oldData: oldData, into: container)

                return merge(oldData: oldData, with: newData)
            }
            .sink(receiveCompletion: { (completion) in
                if case .failure(let error) = completion {
                    // TODO: capture error
                    print("Unable to download new data, reason: \(error.localizedDescription)")
                }
            })
            { (records) in
                self.data = records
            }
    }

    /// Downloads and transforms data from specified configuration.
    /// - Parameter configuration: application configuration
    private func downloadAndTransformData(using configuration: Configuration) -> AnyPublisher<[EstateRecord], Error> {
        var publisher = Empty<[EstateRecord], Error>().eraseToAnyPublisher()

        for agency in configuration.agencies {
            let parser = agency.createParser()

            for URL in agency.filters {
                publisher = publisher.append(downloadData(from: URL, parser: parser)).eraseToAnyPublisher()
            }
        }

        return publisher
    }

    /// Downloads data from specified URL. It may fail either because of network error, or during reading downloaded data.
    /// - Parameter URL: Estate agency's fetch URL
    private func downloadData(from URL: URL, parser: AgencyParser) -> AnyPublisher<[EstateRecord], Error> {
        return URLSession.shared.dataTaskPublisher(for: URL)
                    .compactMap { data, response in String(data: data, encoding: .utf8) }
                    .tryMap { (html) in try parser.parse(html) }
                    .eraseToAnyPublisher()
    }
}

/// Persists newly fetched data. Does not override existing data.
/// - Parameter newData: newly fetched data from network
/// - Parameter oldData: existing data, feched from CoreData storage
/// - Parameter viewContext: CoreData's view context
func persistDifferenceBetween(newData: [EstateRecord], oldData: [EstateRecord], into container: NSPersistentContainer) throws {
    for change in newData.difference(from: oldData) {
        if case .insert(_, let record, _) = change {
            _ = Estate(record: record, context: container.viewContext)
        }
    }
}

/// Merges old and new data together. Then it sorts them by date.
/// - Parameter oldData: existing data (from CoreData storage)
/// - Parameter newData: new data (from network)
private func merge(oldData: [EstateRecord], with newData: [EstateRecord]) -> [EstateRecord] {

    var result = [EstateRecord]()

    result.append(contentsOf: oldData)
    result.append(contentsOf: newData)

    return result.sorted { (first, second) in
        return first.date > second.date
    }
}

private func fetchData(from container: NSPersistentContainer) throws -> [EstateRecord] {
    let request: NSFetchRequest<Estate> = Estate.fetchRequest()

    request.predicate = NSPredicate(format: "status != %@", "Hidden")
    request.sortDescriptors = [NSSortDescriptor(keyPath: \Estate.date, ascending: true)]

    let result = try container.viewContext.fetch(request)
    return result.map { (entity) in EstateRecord(entity: entity) }
}
