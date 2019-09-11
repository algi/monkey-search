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
                let price = Double(item.at_xpath("./div/span/span/@data-price")?.text ?? ""),
                let text = item.at_xpath("./div/div")?.text,
                let previewImageURL = URL(string: item.at_xpath("./div/a/img/@src")?.text ?? "")
            else {
                throw ParserError.missingField(htmlFragment: item.toHTML ?? "No HTML provided")
            }

            let record = EstateRecord(agency: "Dexters",
                                      date: Date(),
                                      detailURL: detailURL,
                                      id: recordID,
                                      name: name,
                                      price: price,
                                      status: .new,
                                      text: text,
                                      previewImageURL: previewImageURL)

            result.append(record)
        }

        return result
    }
}
