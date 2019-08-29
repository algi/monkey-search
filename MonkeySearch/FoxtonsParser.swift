//
//  FoxtonsParser.swift
//  MonkeySearch
//
//  Created by Marian Bouček on 29/08/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import Foundation
import SwiftSoup

struct EstateRecord {

    let agency: String
    let detailURL: URL
    let externalID: String
    let name: String
    let price: Int
    let status: String
    let text: String

}

protocol AgencyParser {

    func parse(_ html: String) throws -> [EstateRecord]

}

class FoxtonsParser: NSObject, AgencyParser {

    func parse(_ html: String) throws -> [EstateRecord] {
        let document = try SwiftSoup.parse(html)

        let result = try document.select("h6")
        print("Got some results: ", result.count)

        return [EstateRecord]()
    }
}
