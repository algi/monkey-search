//
//  MoneyFormatter.swift
//  MonkeySearch
//
//  Created by Marian Bouček on 11/09/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import Foundation

class CurrencyFormatter: NSObject {

    static let shared = CurrencyFormatter()

    let formatter = NumberFormatter()

    override init() {
        formatter.numberStyle = .currency
        formatter.currencySymbol = "£"
    }

    func formattedPrice(_ price: Double) -> String {

        if let result = formatter.string(from: NSNumber(value: price)) {
            return "\(result) pcm"
        }

        return "Not specified"
    }
}
