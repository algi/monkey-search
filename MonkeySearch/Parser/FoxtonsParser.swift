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

        for element in document.xpath("//div[@class='property_wrapper']") {

            guard
                let recordID = element.at_xpath("./div/@id")?.text,
                let propertyName = element.at_xpath("./div/h6")?.text,
                let detailLink = element.at_xpath("./div/h6/a/@href")?.text,
                let detailURL = URL(string: "\(FoxtonsParser.baseURL)\(detailLink)"),
                let price = element.at_xpath("./div/h2/strong/data")?.text,
                let description = element.at_xpath("./div/p[@class='description']")?.text,
                let previewImageURL = findPreviewImageURL(in: element)
            else {
                throw ParserError.missingField(htmlFragment: element.toHTML ?? "No HTML provided")
            }

            let record = EstateRecord(agency: "Foxtons",
                                      date: Date(),
                                      detailURL: detailURL,
                                      id: recordID,
                                      name: propertyName,
                                      price: "£\(price)",
                                      status: "New",
                                      text: description.trimmingCharacters(in: CharacterSet.newlines),
                                      previewImageURL: URL(string: previewImageURL))

            result.append(record)
        }

        return result
    }

    private func findPreviewImageURL(in element: XMLElement) -> String? {

        if let previewImageURL = element.at_xpath("./div/a[@class='property_photo_holder']/@style")?.text {
            return String(previewImageURL
                .dropFirst("background-image:url(".count)
                .dropLast(");".count))
        }

        return element.at_xpath("./div/a[@class='property_photo_holder']/@data-src")?.text
    }
}
