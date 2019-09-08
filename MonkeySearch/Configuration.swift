//
//  Configuration.swift
//  MonkeySearch
//
//  Created by Marian Bouček on 08/09/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import Foundation

struct Agency: Codable {

    let name: String
    let filters: [URL]

    func createParser() -> AgencyParser {
        switch name {
            case "Dexters":
                return DextersParser()
            case "Foxtons":
                return FoxtonsParser()
            default:
                fatalError("Unable to create a parser for agency: \(name)")
        }
    }
}

struct Configuration: Codable {

    let agencies: [Agency]

}

extension Configuration {
    static func defaultConfiguration() throws -> Configuration {

        guard let fileURL = Bundle.main.url(forResource: "Configuration", withExtension: "json") else {
            throw ConfigurationError.fileNotFound
        }

        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()

        return try decoder.decode(Configuration.self, from: data)
    }
}

enum ConfigurationError: Error {
    case fileNotFound
}
