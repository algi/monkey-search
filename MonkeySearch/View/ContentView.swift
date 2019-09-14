//
//  ContentView.swift
//  MonkeySearch
//
//  Created by Marian Bouček on 28/08/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var provider: DataProvider

    var body: some View {
        NavigationView {
            List {
                ForEach(provider.data) { row in
                    NavigationLink(destination: BrowserDetailView(entity: row)) {
                        HStack {
                            Text(row.name)
                            Spacer()
                            Text(CurrencyFormatter.shared.formattedPrice(row.price))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete { (indexSet) in
                    let records = indexSet.map { (index) -> EstateRecord in
                        return self.provider.data[index]
                    }

                    self.provider.markAsHidden(records: records)
                }
            }
            .navigationBarTitle("Browser")
            .navigationBarItems(trailing: Button("Reload") {
                self.provider.refreshData()
            })
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(provider: DataProvider(data: [
            previewData()
        ]))
    }
}
