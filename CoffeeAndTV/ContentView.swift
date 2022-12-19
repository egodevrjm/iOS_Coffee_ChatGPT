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
            .navigationBarItems(trailing:
                NavigationLink(destination: FavoritesView(coffeeList: coffeeList)) {
                    Text("Favorites")
                }
            )
        }
    }
}

struct FavoritesView: View {
    @ObservedObject var coffeeList: CoffeeList

    var body: some View {
        List(coffeeList.favorites) { coffee in
            NavigationLink(destination: CoffeeDetail(coffee: coffee)) {
                Text(coffee.name)
            }
        }
        .navigationBarTitle("Favorites")
    }
}

struct CoffeeDetail: View {
    @ObservedObject var coffee: Coffee
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack(alignment: .bottomLeading) {
                Image("coffee")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                Text(coffee.name)
                    .font(.title)
                    .padding(16)
                    .background(Color.black.opacity(0.5))
                    .foregroundColor(.white)
                    .alignmentGuide(.bottom, computeValue: { d in d[VerticalAlignment.bottom] })
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
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
            }
            HStack {
                if coffee.isFavorite {
                    Button(action: { self.coffee.isFavorite.toggle() }) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                } else {
                    Button(action: { self.coffee.isFavorite.toggle() }) {
                        Image(systemName: "star")
                            .foregroundColor(.gray)
                    }
                }
            }
        }.padding(16)
    }
}



class CoffeeList: ObservableObject {
    @Published var coffees: [Coffee] = []

    var favorites: [Coffee] {
        return coffees.filter { $0.isFavorite }
    }

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

class Coffee: ObservableObject, Codable, Identifiable {
    var id: Int
    var category: String
    var name: String
    var ingredients: [String]
    var steps: [String]
    @Published var isFavorite: Bool = false

    init(id: Int, category: String, name: String, ingredients: [String], steps: [String]) {
        self.id = id
        self.category = category
        self.name = name
        self.ingredients = ingredients
        self.steps = steps
    }

    enum CodingKeys: String, CodingKey {
        case id
        case category
        case name
        case ingredients
        case steps
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        category = try container.decode(String.self, forKey: .category)
        name = try container.decode(String.self, forKey: .name)
        ingredients = try container.decode([String].self, forKey: .ingredients)
        steps = try container.decode([String].self, forKey: .steps)
    }
}


struct CoffeeData: Codable {
    var recipes: [Coffee]
}

