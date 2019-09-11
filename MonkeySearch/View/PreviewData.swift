//
//  PreviewData.swift
//  MonkeySearch
//
//  Created by Marian Bouček on 09/09/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import Foundation

func previewData() -> EstateRecord {
    return EstateRecord(agency: "Foxtons",
                        date: Date(),
                        detailURL: URL(string: "https://www.foxtons.co.uk/properties-to-rent/nw3/hmpd0183781")!,
                        id: "1",
                        name: "44 Priory Road",
                        price: "£400",
                        status: "New",
                        text: "An excellent two bedroom, first floor apartment located in an imposing period conversion and boasting high ceilings and wood floors, plus access to spacious communal gardens.",
                        previewImageURL: URL(string: "https://a19c53f45b440f049d21-3f2703e71e5f5fed646a243f2d21abcb.ssl.cf3.rackcdn.com/property_image.378cm276.v1/to-rent/Barrenger-Road-London-N10/123709/123709_exrevchq64fedlkye032wr6ni.jpg")
                        )
}
