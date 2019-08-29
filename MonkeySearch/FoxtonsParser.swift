//
//  FoxtonsParser.swift
//  MonkeySearch
//
//  Created by Marian Bouček on 29/08/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import Foundation
import Kanna

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

class FoxtonsParser: NSObject, AgencyParser {

    private static let baseURL = "https://www.foxtons.co.uk"

    func parse(_ html: String) throws -> [EstateRecord] {
        let document = try HTML(html: html, encoding: .utf8)
        var result = [EstateRecord]()

        for item in document.xpath("//div[@class='property_summary']") {

            guard
                let recordID = item.xpath("./@id").first?.text,
                let propertyName = item.xpath("./h6").first?.text,
                let detailLink = item.xpath("./h6/a/@href").first?.text,
                let detailURL = URL(string: "\(FoxtonsParser.baseURL)\(detailLink)"),
                let price = item.xpath("./h2/strong/data").first?.text,
                let description = item.xpath("./p[@class='description']").first?.text
            else {
                throw ParserError.missingField // TODO: add field name
            }

            let record = EstateRecord(agency: "Foxtons",
                                      detailURL: detailURL,
                                      id: recordID,
                                      name: propertyName,
                                      price: "£\(price)",
                                      status: "New",
                                      text: description.trimmingCharacters(in: CharacterSet.newlines))

            result.append(record)
        }

        return result
    }
}

enum ParserError: Error {
    case missingField
}
