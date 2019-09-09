//
//  ContentView.swift
//  MonkeySearch
//
//  Created by Marian Bouček on 28/08/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    let provider: DataProvider

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List(provider.data) { row in
                    NavigationLink(destination: BrowserDetailView(entity: row)) {
                        HStack {
                            Text(row.name)
                            Spacer()
                            Text(row.price)
                                .foregroundColor(.gray)
                        }
                    }
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
            EstateRecord(agency: "Foxtons",
                         date: Date(),
                         detailURL: URL(string: "https://www.foxtons.co.uk")!,
                         id: "1",
                         name: "44 Priory Road",
                         price: "£400",
                         status: "New",
                         text: "Sample text.")
        ]))
    }
}
