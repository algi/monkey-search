//
//  EstateRecord.swift
//  MonkeySearch
//
//  Created by Marian Bouček on 11/09/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import Foundation

struct EstateRecord: Identifiable {

    let agency: String
    let date: Date
    let detailURL: URL
    let id: String
    let name: String
    let price: Double
    let status: RecordStatus
    let text: String
    let previewImageURL: URL

    var isNew: Bool {
        return status == .new
    }
}

enum RecordStatus {

    case new
    case visited
    case hidden

    static func from(string: String) -> RecordStatus {
        switch string {
            case "New":
                return .new
            case "Visited":
                return .visited
            case "Hidden":
                return .hidden
            default:
                fatalError("Unknown status: \(string)")
        }
    }

    func string() -> String {
        switch self {
            case .new:
                return "New"
            case .visited:
                return "Visited"
            case .hidden:
                return "Hidden"
        }
    }
}
