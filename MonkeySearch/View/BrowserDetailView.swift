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
                Text(CurrencyFormatter.shared.formattedPrice(entity.price))

                Spacer()
                Text(entity.status.string())
                    .fontWeight(.bold)
            }

            HStack {
                Text("Agency:").fontWeight(.bold)
                Text(entity.agency)
            }

            Text("Description:").fontWeight(.bold)
            Text(entity.text)

            Text("Photos:").fontWeight(.bold)
            previewImage()

            Spacer()

            HStack {
                Button("Accept") {
                    self.acceptEstate()
                }
                Spacer()
                Button("Deny") {
                    self.denyEstate()
                }.foregroundColor(.red)
            }
        }
        .padding()
        .navigationBarTitle(entity.name)
        .navigationBarItems(trailing: Button("Open in browser") {
            UIApplication.shared.open(self.entity.detailURL)
        })
    }

    private func previewImage() -> AnyView {
        // TODO: do not load on main thread + cache the image
        if let data = try? Data(contentsOf: entity.previewImageURL), let image = UIImage(data: data) {
            return AnyView(Image(uiImage: image))
        }
        else {
            return AnyView(Text("No preview image available."))
        }
    }

    private func acceptEstate() {
        // TODO: implement me
    }

    private func denyEstate() {
        // TODO: implement me
    }
}

struct BrowserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BrowserDetailView(entity: previewData())
        }
    }
}
