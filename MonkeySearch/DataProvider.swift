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

    private let container: DataContainer?
    private var cancelable: AnyCancellable?

    init(data: [EstateRecord]) {
        self.data = data
        self.container = nil
    }

    init(container: DataContainer) {
        self.container = container

        do {
            self.data = try container.fetchData()
        }
        catch {
            // TODO: capture error
            print("Unable to fetch records, error: \(error.localizedDescription)")
            self.data = [EstateRecord]()
        }
    }

    /// Downloads new data from the internet and merges them with existing data.
    func refreshData(using configuration: Configuration? = nil) {

        // ignore the call, if container is not specified (called from Preview)
        guard let container = container else {
            return
        }

        let config = readConfiguration(configuration: configuration)

        cancelable = downloadAndTransformData(using: config)
            .collect()
            .reduce([EstateRecord](), self.reduceRecords)
            .tryMap { newData in try container.merge(newData: newData) }
            .receive(on: RunLoop.main)
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

    func markAsViewed(record: EstateRecord) {
        // ignore call for preview scenario
        guard let container = container else { return }

        do {
            try container.markAsViewed(record: record)
            try data = container.fetchData()
        }
        catch {
            print("Unable to mark record: \(record) as viewed. Error: \(error.localizedDescription)")
        }
    }

    func markAsHidden(records: [EstateRecord]) {
        // ignore call for preview scenario
        guard let container = container else { return }

        do {
            try container.markAsHidden(records: records)
            try data = container.fetchData()
        }
        catch {
            print("Unable to mark following records as hidden: \(records), error: \(error.localizedDescription)")
        }
    }

    /// Provides configuration either from the parameter, or default one.
    /// - Parameter configuration: external configuration
    private func readConfiguration(configuration: Configuration?) -> Configuration {
        if let configuration = configuration {
            return configuration
        }

        do {
            return try Configuration.defaultConfiguration()
        }
        catch {
            fatalError("Unable to create default configuration. Error: \(error.localizedDescription)")
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

    /// Reduces records to one array
    /// - Parameter initialResult: initial empty array
    /// - Parameter records: array of arrays with records
    private func reduceRecords(initialResult: [EstateRecord], records: [[EstateRecord]]) -> [EstateRecord] {
        return records.reduce(into: initialResult) { (result, records) in
            result.append(contentsOf: records)
        }
    }
}
