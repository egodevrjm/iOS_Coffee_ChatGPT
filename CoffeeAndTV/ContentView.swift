import SwiftUI
import PDFKit

struct ContentView: View {
    @ObservedObject var coffeeList = CoffeeList()

    var body: some View {
        NavigationView {
            List(coffeeList.coffees) { coffee in
                NavigationLink(destination: CoffeeDetail(coffee: coffee)) {
                    HStack {
                        Image("\(coffee.id)")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        Text(coffee.name)
                    }
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
                HStack {
                    Image("\(coffee.id)")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    Text(coffee.name)
                }
            }
        }
        .navigationBarTitle("Favorites")
    }
}


struct CoffeeDetail: View {
    @ObservedObject var coffee: Coffee

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image("\(coffee.id)")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
            Text(coffee.name)
                .font(.title)
                .padding(16)
                .background(Color.black.opacity(0.5))
                .foregroundColor(.white)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Category: \(coffee.category)")
                        .font(.subheadline)
                    Text("Ingredients:")
                        .font(.headline)
                    ForEach(coffee.ingredients, id: \.self) { ingredient in
                        HStack {
                            Circle()
                                .foregroundColor(.green)
                                .frame(width: 10, height: 10)
                            Text(ingredient)
                        }
                    }
                    Text("Steps:")
                        .font(.headline)
                    ForEach(coffee.steps, id: \.self) { step in
                        HStack {
                            Circle()
                                .foregroundColor(.green)
                                .frame(width: 10, height: 10)
                            Text(step)
                        }
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack(alignment: .center) {
                if coffee.isFavorite {
                    Button(action: { self.coffee.isFavorite.toggle() }) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.largeTitle)
                    }
                } else {
                    Button(action: { self.coffee.isFavorite.toggle() }) {
                        Image(systemName: "star")
                            .foregroundColor(.gray)
                            .font(.largeTitle)
                    }
                }
                Spacer()
                Button(action: {
                    let recipeText = """
                    Recipe for \(self.coffee.name):
                    Category: \(self.coffee.category)
                    Ingredients:
                    """
                    + self.coffee.ingredients.map { " - \($0)" }.joined(separator: "\n")
                    + """
                    Steps:
                    """
                    + self.coffee.steps.map { " - \($0)" }.joined(separator: "\n")
                    let activityViewController = UIActivityViewController(activityItems: [recipeText], applicationActivities: nil)
                    UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.blue)
                        .font(.largeTitle)
                }

            }.padding(.top, 16)
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

