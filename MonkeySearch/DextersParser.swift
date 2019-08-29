//
//  DextersParser.swift
//  MonkeySearch
//
//  Created by Marian Bouček on 29/08/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import Foundation
import Kanna

class DextersParser: AgencyParser {

    private static let baseURL = "https://www.dexters.co.uk"
    
    func parse(_ html: String) throws -> [EstateRecord] {
        let document = try HTML(html: html, encoding: .utf8)
        var result = [EstateRecord]()

        for item in document.xpath("//li[@class='result item to-let infinite-item']") {

            guard
                let detailLink = item.at_xpath("./div/h3/a/@href")?.text,
                let detailURL = URL(string: "\(DextersParser.baseURL)\(detailLink)"),
                let recordID = item.at_xpath("./@data-property-id")?.text,
                let name = item.at_xpath("./div/h3")?.text,
                let price = item.at_xpath("./div/span/span/@data-price")?.text,
                let text = item.at_xpath("./div/div")?.text
            else {
                throw ParserError.missingField // TODO: field name
            }

            let record = EstateRecord(agency: "Dexters",
                                      detailURL: detailURL,
                                      id: recordID,
                                      name: name,
                                      price: "£\(price) pcm",
                                      status: "New",
                                      text: text)

            result.append(record)
        }

        return result
    }
}
