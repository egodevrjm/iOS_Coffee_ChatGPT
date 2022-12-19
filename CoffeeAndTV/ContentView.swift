//
//  ContentView.swift
//  CoffeeAndTV
//
//  Created by Ryan Morrison on 19/12/2022.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var coffeeList = CoffeeList()

    var body: some View {
        NavigationView {
            List(coffeeList.coffees) { coffee in
                NavigationLink(destination: CoffeeDetail(coffee: coffee)) {
                    Text(coffee.name)
                }
            }
            .navigationBarTitle("Coffee Recipes")
        }
    }
}

struct CoffeeDetail: View {
    var coffee: Coffee

    var body: some View {
        VStack(alignment: .leading) {
            Text(coffee.name)
                .font(.title)
            Text("Category: \(coffee.category)")
                .font(.subheadline)
            Text("Ingredients:")
                .font(.headline)
            ForEach(coffee.ingredients, id: \.self) { ingredient in
                Text("- \(ingredient)")
            }
            Text("Steps:")
                .font(.headline)
            ForEach(coffee.steps, id: \.self) { step in
                Text("- \(step)")
            }
        }
        .padding()
    }
}

class CoffeeList: ObservableObject {
    @Published var coffees: [Coffee] = []

    init() {
        let url = URL(string: "https://atripto.space/exp/coffee.json")!

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if let data = data {
                    let coffeeData = try JSONDecoder().decode(CoffeeData.self, from: data)
                    DispatchQueue.main.async {
                        self.coffees = coffeeData.recipes
                    }
                } else {
                    print("No data")
                }
            } catch {
                print("Error: \(error)")
            }
        }.resume()
    }
}

struct Coffee: Codable, Identifiable {
    var id: Int
    var category: String
    var name: String
    var ingredients: [String]
    var steps: [String]
}

struct CoffeeData: Codable {
    var recipes: [Coffee]
}
