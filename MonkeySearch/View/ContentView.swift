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
                ForEach(provider.data) { record in
                    NavigationLink(destination: self.detailView(for: record)) {
                        HStack {
                            if record.isNew {
                                NewRecordIndicator()
                            }
                            else {
                                NewRecordIndicator().hidden()
                            }

                            Text(record.name)
                            Spacer()
                            Text(CurrencyFormatter.shared.formattedPrice(record.price))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: markAsHidden)
            }
            .navigationBarTitle("Browser")
            .navigationBarItems(trailing: Button("Reload") {
                self.provider.refreshData()
            })
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
        }
    }

    func detailView(for record: EstateRecord) -> some View {
        return BrowserDetailView(entity: record).onAppear {
            self.markAsViewed(record: record)
        }
    }

    func markAsViewed(record: EstateRecord) {
        provider.markAsViewed(record: record)
    }

    func markAsHidden(indexSet: IndexSet) {
        let records = indexSet.map { (index) in provider.data[index] }
        provider.markAsHidden(records: records)
    }
}

struct NewRecordIndicator: View {
    var body: some View {
        Circle()
            .frame(width: 10, height: 10, alignment: .center)
            .foregroundColor(.blue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(provider: DataProvider(data: [
            previewData(id: "1", status: .new),
            previewData(id: "2", status: .visited)
        ]))
    }
}
