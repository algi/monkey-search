//
//  DataProcessor.swift
//  MonkeySearch
//
//  Created by Marian Bouček on 03/09/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import Combine
import CoreData

enum Agency {

    case dexters
    case foxtons

}

struct Configuration {

    let agency: Agency
    let url: URL

}

func fetchNewData() -> AnyPublisher<[EstateRecord], Error> {

    /*
     1. načti data z internetu
     2. načtu existující záznamy, které nejsou skryté a transformuj je na ‹EstateRecord›
     3. najdi nové záznamy (porovnej internetové s existujícími z CoreData)
     4. ulož nové záznamy do CoreData
     5. zkombinuj staré a nové záznamy
     6. setřiď dle data (od nejmladšího)
     */

    guard let URL = URL(string: "https://www.foxtons.co.uk/properties-to-rent/muswell-hill-n10/?price_to=500&bedrooms_from=2&expand=2") else {
        fatalError("Invalid fetch URL.")
    }

    let foxtons = Configuration(agency: .foxtons, url: URL)

    return downloadData(from: foxtons.url)
        .tryMap { (html) in try FoxtonsParser().parse(html) }
        .eraseToAnyPublisher()
}

/// Downloads data from specified URL. It may fail either because of network error, or during reading downloaded data.
/// - Parameter URL: Estate agency's fetch URL
// https://www.foxtons.co.uk/properties-to-rent/muswell-hill-n10/?price_to=500&bedrooms_from=2&expand=2
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

func transform(html: String, forAgency agency: String) throws -> [EstateRecord] {
    switch agency {
        case "Foxtons":
            return try FoxtonsParser().parse(html)
        default:
            fatalError()
    }
}

func fetchPersistedData(from context: NSManagedObjectContext) throws -> [EstateRecord] {

    let request: NSFetchRequest<Estate> = Estate.fetchRequest()
    request.predicate = NSPredicate(format: "state != %@", "Hidden")

    let entities = try context.fetch(request)

    return entities.map { (entity) in EstateRecord(entity: entity) }
}

extension EstateRecord {

    init(entity: Estate) {
        self.agency = entity.agency ?? "Unknown"
        self.detailURL = entity.detailURL ?? URL(string: "http://www.apple.com")!
        self.id = entity.externalID ?? ""
        self.name = entity.name ?? "No address"
        self.price = "\(entity.price)"
        self.status = entity.status ?? "New"
        self.text = entity.text ?? "No description"
    }
}
