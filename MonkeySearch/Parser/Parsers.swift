//
//  Parsers.swift
//  MonkeySearch
//
//  Created by Marian Bouček on 04/09/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import Foundation

struct EstateRecord: Identifiable {

    let agency: String
    let date: Date
    let detailURL: URL
    let id: String
    let name: String
    let price: Double
    let status: RecordStatus
    let text: String
    let previewImageURL: URL

}

enum RecordStatus {

    case new
    case visited
    case hidden

    static func from(string: String) -> RecordStatus {
        switch string {
            case "New":
                return .new
            case "Visited":
                return .visited
            case "Hidden":
                return .hidden
            default:
                fatalError("Unknown status: \(string)")
        }
    }

    func string() -> String {
        switch self {
            case .new:
                return "New"
            case .visited:
                return "Visited"
            case .hidden:
                return "Hidden"
        }
    }
}

protocol AgencyParser {

    func parse(_ html: String) throws -> [EstateRecord]

}

enum ParserError: LocalizedError {

    case missingField(htmlFragment: String)

    var errorDescription: String? {
        switch self {
            case .missingField(let htmlFragment):
                return "Unable to parse fragment: '\(htmlFragment)'"
        }
    }
}
