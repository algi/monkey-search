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
            .reduce([EstateRecord](), self.reduceRecords)
            .tryMap { newData in try container.merge(newData: newData) }
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

    /// Reduces records to one array
    /// - Parameter initialResult: initial empty array
    /// - Parameter records: array of arrays with records
    private func reduceRecords(initialResult: [EstateRecord], records: [[EstateRecord]]) -> [EstateRecord] {
        return records.reduce(into: initialResult) { (result, records) in
            result.append(contentsOf: records)
        }
    }
}
