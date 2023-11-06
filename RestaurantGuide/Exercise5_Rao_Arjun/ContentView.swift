import SwiftUI

struct Restaurant: Decodable, Identifiable {
    let name: String
    let free: String
    let phone: String
    let logo: String
    let map: String
    let lots: String
    let about: String
    
    var id: String {
        name
    }
}


class RestaurantViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    
    func load() {
        let urlString = "https://m.cpl.uh.edu/courses/ubicomp/fall2022/webservice/restaurant/restaurants.json"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data {
                        do {
                            let decodedRestaurants = try JSONDecoder().decode([Restaurant].self, from: data)
                            DispatchQueue.main.async {
                                self.restaurants = decodedRestaurants
                            }
                        } catch {
                            print("Error decoding JSON: \(error)")
                        }
                    } else if let error = error {
                        print("Error fetching data: \(error)")
                    }
                }
                task.resume()
            }
        }

struct DetailView: View {
    let restaurant: Restaurant
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > geometry.size.height {
                ScrollView {
                    HStack {
                        if let mapUrl = URL(string: restaurant.map) {
                            AsyncImage(url: mapUrl) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)
                            .padding()
                        }
                        
                        VStack {
                            if let logoUrl = URL(string: restaurant.logo) {
                                AsyncImage(url: logoUrl) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 100, height: 70)
                                .padding()
                            }
                            
                            Text("P: \(restaurant.lots)")
                                .padding()
                                .bold()
                            
                            Text("About: \(restaurant.about)")
                                .padding()
                            
                            Text("\(restaurant.phone)")
                        }
                    }
                }
            } else {
                ScrollView {
                        VStack {
                            if let mapUrl = URL(string: restaurant.map) {
                                AsyncImage(url: mapUrl) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 300, height: 300)
                            }
                            
                            if let logoUrl = URL(string: restaurant.logo) {
                                AsyncImage(url: logoUrl) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 100, height: 70)
                            }
                            
                            Text("P: \(restaurant.lots)")
                                .bold()
                            
                            Text("About: \(restaurant.about)")
                                .padding()
                            
                            Text("\(restaurant.phone)")
                        }
                    }
                }
            }
        }
    }




struct ContentView: View {
    @StateObject var viewModel = RestaurantViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(viewModel.restaurants) { restaurant in
                        NavigationLink(destination: DetailView(restaurant: restaurant)) {
                            ZStack {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(maxWidth: .infinity)
                                    .contentShape(Rectangle())
                                
                                HStack {
                                    if let url = URL(string: restaurant.logo) {
                                        AsyncImage(url: url) { image in
                                            image.resizable()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(width: 100, height: 70)
                                        .padding()
                                    }
                                    
                                    Spacer()
                                    
                                    Text(restaurant.free)
                                        .bold()
                                        .foregroundColor(Color.black)
                                        .padding()
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        Divider()
                    }
                }
            }
            .onAppear {
                viewModel.load()
            }
        }
    }
}
