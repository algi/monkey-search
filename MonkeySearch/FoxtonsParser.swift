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

    func parse(_ html: String) throws -> [EstateRecord] {
        let document = try HTML(html: html, encoding: .utf8)
        var result = [EstateRecord]()

        for propertySummary in document.xpath("//div[@class='property_summary']") {

            guard
                let recordID = propertySummary.xpath("./@id").first?.text,
                let propertyName = propertySummary.xpath("./h6").first?.text,
                let detailLink = propertySummary.xpath("./h6/a/@href").first?.text,
                let detailURL = URL(string: "https://www.foxtons.co.uk\(detailLink)"),
                let price = propertySummary.xpath("./h2/strong/data").first?.text
            else {
                throw ParserError.missingField // TODO: add field name
            }

            let record = EstateRecord(agency: "Foxtons",
                                      detailURL: detailURL,
                                      id: recordID,
                                      name: propertyName,
                                      price: "£\(price)",
                                      status: "New",
                                      text: "xxx") // TODO: property description

            result.append(record)
        }

        return result
    }
}

enum ParserError: Error {
    case missingField
}
