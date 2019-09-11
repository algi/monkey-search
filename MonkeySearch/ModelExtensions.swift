//
//  DataProcessor.swift
//  MonkeySearch
//
//  Created by Marian Bouček on 03/09/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import CoreData

extension EstateRecord: Equatable {
    static func == (lhs: EstateRecord, rhs: EstateRecord) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Estate {
    convenience init(record: EstateRecord, context: NSManagedObjectContext) {
        self.init(context: context)

        self.agency = record.agency
        self.detailURL = record.detailURL
        self.date = record.date
        self.externalID = record.id
        self.name = record.name
        self.price = Int16(record.price) ?? 0
        self.status = record.status
        self.text = record.text
        self.previewImageURL = record.previewImageURL
    }
}

extension EstateRecord {

    init(entity: Estate) {
        self.agency = entity.agency ?? "Unknown"
        self.detailURL = entity.detailURL ?? URL(string: "http://www.apple.com")!
        self.date = entity.date ?? Date()
        self.id = entity.externalID ?? "-1"
        self.name = entity.name ?? "No address"
        self.price = "\(entity.price)"
        self.status = entity.status ?? "New"
        self.text = entity.text ?? "No description"
        self.previewImageURL = entity.previewImageURL
    }
}
