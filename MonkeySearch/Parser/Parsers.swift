//
//  Parsers.swift
//  MonkeySearch
//
//  Created by Marian Bouček on 04/09/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import Foundation

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
