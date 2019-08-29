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
        VStack {
            Text("Hello World!")
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
            .padding()
        }
        .navigationBarTitle(entity.name ?? "Detail")
    }
}

struct BrowserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BrowserDetailView(entity: Estate(context: AppDelegate.shared.persistentContainer.viewContext))
    }
}
