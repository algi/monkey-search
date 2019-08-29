//
//  BrowserDetailView.swift
//  MonkeySearch
//
//  Created by Marian Bouček on 28/08/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import SwiftUI

struct BrowserDetailView: View {

    let entity: Estate

    var body: some View {
        VStack(alignment: .leading) {

            HStack {
                Text("Price:").fontWeight(.bold)
                Text("£\(entity.price) pw")
            }

            HStack {
                Text("Agency:").fontWeight(.bold)
                Text(entity.agency ?? "None")
            }

            Text("Description:").fontWeight(.bold)
            Text(entity.text ?? "No description")

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
        .navigationBarTitle(entity.name ?? "Real Estate Detail")
        .navigationBarItems(trailing: Button("Open in browser") {
            // ...
        })
    }
}

#if DEBUG
private func previewData() -> Estate {
    let result = Estate(context: AppDelegate.shared.persistentContainer.viewContext)

    result.agency = "Foxtons"
    result.text = "An excellent two bedroom, first floor apartment located in an imposing period conversion and boasting high ceilings and wood floors, plus access to spacious communal gardens."
    result.name = "44 Priory Road"
    result.price = 400

    return result
}

struct BrowserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BrowserDetailView(entity: previewData())
        }
    }
}
#endif
