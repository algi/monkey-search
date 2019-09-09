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

    func refreshData() {

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
            // TODO: process data (store them in CoreData)
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

                let parsedRecords = downloadData(from: URL).tryMap { (html) in
                    try parser.parse(html)
                }

                publisher = publisher.append(parsedRecords).eraseToAnyPublisher()
            }
        }

        return publisher
    }

    /// Downloads data from specified URL. It may fail either because of network error, or during reading downloaded data.
    /// - Parameter URL: Estate agency's fetch URL
    private func downloadData(from URL: URL) -> Future<String, Error> {
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
}

private func fetchData(from container: NSPersistentContainer) throws -> [EstateRecord] {
    let request: NSFetchRequest<Estate> = Estate.fetchRequest()

    request.predicate = NSPredicate(format: "status != %@", "Hidden")
    request.sortDescriptors = [NSSortDescriptor(keyPath: \Estate.date, ascending: true)]

    let result = try container.viewContext.fetch(request)
    return result.map { (entity) in EstateRecord(entity: entity) }
}
