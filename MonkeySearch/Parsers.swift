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
    let detailURL: URL
    let id: String
    let name: String
    let price: String
    let status: String
    let text: String

}

protocol AgencyParser {

    func parse(_ html: String) throws -> [EstateRecord]

}

enum ParserError: Error {
    case missingField
}
