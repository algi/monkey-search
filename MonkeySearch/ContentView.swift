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

//    @FetchRequest(fetchRequest: fetchRequest()) var data: FetchedResults<Estate>
    @State private var data = [EstateRecord]()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List(data) { row in
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
                fetchNewData { (records) in
                    self.data = records
                }
            })
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
        }
    }
}

private func fetchRequest() -> NSFetchRequest<Estate> {
    let request: NSFetchRequest<Estate> = Estate.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(keyPath: \Estate.name, ascending: true)]
    request.predicate = NSPredicate(format: "status == %@", "New");

    return request
}

private func fetchNewData(completionHandler: @escaping ([EstateRecord]) -> Void) {
    guard let fetchURL = URL(string: "https://www.foxtons.co.uk/properties-to-rent/muswell-hill-n10/?price_to=500&bedrooms_from=2&expand=2") else {
        print("Unable to parse fetch URL for Foxtons.")
        return
    }

    let task = URLSession.shared.downloadTask(with: fetchURL) { (location, response, error) in
        if let error = error {
            print("Unable to fetch data, reason: \(error.localizedDescription)")
            return
        }

        guard let location = location else {
            print("Unable to find location with downloaded data.")
            return
        }

        print("Got document at location: \(location)")

        do {
            let html = try String(contentsOf: location)
            let result = try FoxtonsParser().parse(html)

            // TODO: map to entities, etc.
            completionHandler(result)
        }
        catch {
            print("Unable to parse HTML document, reason: \(error.localizedDescription)")
        }
    }
    task.resume()
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, AppDelegate.shared.persistentContainer.viewContext)
    }
}
