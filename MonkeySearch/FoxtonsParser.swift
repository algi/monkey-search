//
//  FoxtonsParser.swift
//  MonkeySearch
//
//  Created by Marian Bouček on 29/08/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import Foundation
import Kanna

class FoxtonsParser: NSObject, AgencyParser {

    private static let baseURL = "https://www.foxtons.co.uk"

    func parse(_ html: String) throws -> [EstateRecord] {
        let document = try HTML(html: html, encoding: .utf8)
        var result = [EstateRecord]()

        for item in document.xpath("//div[@class='property_summary']") {

            guard
                let recordID = item.at_xpath("./@id")?.text,
                let propertyName = item.at_xpath("./h6")?.text,
                let detailLink = item.at_xpath("./h6/a/@href")?.text,
                let detailURL = URL(string: "\(FoxtonsParser.baseURL)\(detailLink)"),
                let price = item.at_xpath("./h2/strong/data")?.text,
                let description = item.at_xpath("./p[@class='description']")?.text
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
