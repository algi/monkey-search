//
//  PreviewData.swift
//  MonkeySearch
//
//  Created by Marian Bouček on 09/09/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import Foundation

func previewData(id: String = "1", status: RecordStatus = .new) -> EstateRecord {
    return EstateRecord(agency: "Foxtons",
                        date: Date(),
                        detailURL: URL(string: "https://www.foxtons.co.uk/properties-to-rent/nw3/hmpd0183781")!,
                        id: id,
                        name: "44 Priory Road",
                        price: 400,
                        status: status,
                        text: "An excellent two bedroom, first floor apartment located in an imposing period conversion and boasting high ceilings and wood floors, plus access to spacious communal gardens. An excellent two bedroom, first floor apartment located in an imposing period conversion and boasting high ceilings and wood floors, plus access to spacious communal gardens.",
                        previewImageURL: URL(string: "https://assets.foxtons.co.uk/w/480/1565109473/chpk2750858-1.jpg")!
                        )
}
