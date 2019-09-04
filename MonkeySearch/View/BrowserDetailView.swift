//
//  BrowserDetailView.swift
//  MonkeySearch
//
//  Created by Marian Bouček on 28/08/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import SwiftUI

struct BrowserDetailView: View {

    let entity: EstateRecord

    var body: some View {
        VStack(alignment: .leading) {

            HStack {
                Text("Price:").fontWeight(.bold)
                Text(entity.price)
            }

            HStack {
                Text("Agency:").fontWeight(.bold)
                Text(entity.agency)
            }

            Text("Description:").fontWeight(.bold)
            Text(entity.text)

            Text("Photos:").fontWeight(.bold)
            Text("No photos available.") // TODO: fotky

            Spacer()

            HStack {
                Button("Accept") {
                    // ...
                }
                Spacer()
                Button("Deny") {
                    // ...
                }.foregroundColor(.red)
            }
        }
        .padding()
        .navigationBarTitle(entity.name)
        .navigationBarItems(trailing: Button("Open in browser") {
            UIApplication.shared.open(self.entity.detailURL)
        })
    }
}

#if DEBUG
private func previewData() -> EstateRecord {
    return EstateRecord(agency: "Foxtons",
                        date: Date(),
                        detailURL: URL(string: "https://www.foxtons.co.uk/properties-to-rent/nw3/hmpd0183781")!,
                        id: "1",
                        name: "44 Priory Road",
                        price: "400",
                        status: "New",
                        text: "An excellent two bedroom, first floor apartment located in an imposing period conversion and boasting high ceilings and wood floors, plus access to spacious communal gardens.")
}

struct BrowserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BrowserDetailView(entity: previewData())
        }
    }
}
#endif
