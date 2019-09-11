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
                    // TODO: implement Accept button
                }
                Spacer()
                Button("Deny") {
                    // TODO: implement Deny button
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
}

struct BrowserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BrowserDetailView(entity: previewData())
        }
    }
}
