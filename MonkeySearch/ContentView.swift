//
//  ContentView.swift
//  MonkeySearch
//
//  Created by Marian Bouček on 28/08/2019.
//  Copyright © 2019 Marian Bouček. All rights reserved.
//

import CoreData
import SwiftUI

// hmm... 🤔
extension Estate: Identifiable {}

struct ContentView: View {

//    @Environment(\.managedObjectContext) var viewContext: NSManagedObjectContext
    @FetchRequest(fetchRequest: fetchRequest()) var data: FetchedResults<Estate>

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List(data) { row in
                    NavigationLink(destination: BrowserDetailView(entity: row)) {
                        HStack {
                            Text(row.name ?? "<Unknown>")
                            Spacer()
                            Text("£\(row.price)")
                                .foregroundColor(.gray)
                        }
                    }
                }

                HStack {
                    Text("Status:").fontWeight(.bold)
                    Text("Done")
                }
//                .background(Rectangle().foregroundColor(.gray))
                .padding()
            }
            .navigationBarTitle("Browser")
            .navigationBarItems(trailing: Button("Reload") {
                // fetch new data on background queue, then update CoreData
                // @FetchRequest will automatically reload the data

                let newRecord = Estate(context: AppDelegate.shared.persistentContainer.viewContext)

                newRecord.name = "New Record"
                newRecord.status = "New"
            })
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
        }
    }

    static func fetchRequest() -> NSFetchRequest<Estate> {
        let request: NSFetchRequest<Estate> = Estate.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Estate.name, ascending: true)]
        request.predicate = NSPredicate(format: "status == %@", "New");

        return request
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, AppDelegate.shared.persistentContainer.viewContext)
    }
}
