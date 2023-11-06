import SwiftUI
import Combine
import MapKit

struct Person: Identifiable, Decodable {
    let id: Int
    let distance: Int
    let type: String
    let name: String
    let location: String
    let lati: Double
    let longi: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lati, longitude: longi)
    }
}

class PeopleViewModel: ObservableObject {
    @Published var people: [Person] = []
    
    var cancellable: AnyCancellable?
    
    init() {
        loadPeople()
    }
    
    func loadPeople() {
        let url = URL(string: "https://m.cpl.uh.edu/courses/ubicomp/fall2022/webservice/people.json")!
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Person].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching data: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { people in
                self.people = people
            })
    }
    var uniqueTypes: [String] {
        Set(people.map { $0.type }).sorted()
    }
}

struct ContentView: View {
    @StateObject var viewModel = PeopleViewModel()
    @State private var selectedGroup: String? = nil
    @State private var isGroupSelectionPresented: Bool = false
    
    var filteredPeople: [Person] {
        if let group = selectedGroup {
            return viewModel.people.filter { $0.type == group }
        }
        return viewModel.people
    }
    
    var buttonText: String {
        if let selectedGroup = selectedGroup {
            return "\(selectedGroup) somewhere near me"
        } else {
            return "Everyone somewhere near me"
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                NavigationLink(destination: GroupSelectionView(selectedGroup: $selectedGroup, groups: viewModel.uniqueTypes, buttonText: buttonText), isActive: $isGroupSelectionPresented) {
                    EmptyView()
                }
                .hidden()
                
                Button(action: {
                    isGroupSelectionPresented.toggle()
                }) {
                    Text(buttonText)
                        .font(.system(size: 45))
                        .foregroundColor(.blue)
                        .padding(.top)
                }

                List(filteredPeople) { person in
                    NavigationLink(destination: PersonDetailView(person: person)) {
                        HStack {
                            Text(person.name)
                                .font(.system(size: 20))
                                .bold()
                                .foregroundColor(Color(red: 0/255, green: 102/255, blue: 153/255))
                            Spacer()
                            Text("\(person.distance) miles")
                                .font(.system(size: 15))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(Color(red: 0/255, green: 102/255, blue: 153/255))
                                .bold()
                        }
                    }
                }

                Spacer()
            }
        }
    }
}

struct GroupSelectionView: View {
    @Binding var selectedGroup: String?
    let groups: [String]
    let buttonText: String

    var body: some View {
        NavigationView {
            VStack {
                Text(buttonText)
                    .font(.system(size: 45))
                    .foregroundColor(.blue)
                    .padding(.top)

                List(["Everyone"] + groups, id: \.self) { group in
                    Button(action: {
                        selectedGroup = group == "Everyone" ? nil : group
                    }) {
                        Text(group)
                            .font(.system(size: 35))
                            .foregroundColor(Color(red: 0/255, green: 153/255, blue: 255/255))
                            .bold()
                    }
                }
            }
        }
    }
}

struct PersonDetailView: View {
    let person: Person
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            VStack(spacing: 20) {
                Spacer()
                Text(person.name)
                    .foregroundColor(Color(red: 0/255, green: 153/255, blue: 255/255))
                    .font(.system(size: 45))
                    .bold()
                Spacer()
                Text("Distance: \(person.distance) m")
                    .foregroundColor(Color(red: 0/255, green: 102/255, blue: 153/255))
                    .font(.system(size: 45))
                Text("At: \(person.location)")
                    .foregroundColor(Color(red: 0/255, green: 102/255, blue: 153/255))
                    .font(.system(size: 45))
                Spacer()
                Text("You are: \(person.type)")
                    .foregroundColor(Color(red: 0/255, green: 102/255, blue: 153/255))
                    .font(.system(size: 45))
                Spacer()
            }
            .tabItem {
                Label("Details", systemImage: "info.circle")
            }
            .tag(0)
            
            CustomMapView(person: person)
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(1)
        }
        .padding()
    }
}

struct CustomMapView: UIViewRepresentable {
    var person: Person
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        let coordinate = CLLocationCoordinate2D(latitude: person.lati, longitude: person.longi)
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        uiView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(person.name) is here"
        
        let location = CLLocation(latitude: person.lati, longitude: person.longi)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard let placemark = placemarks?.first else { return }
            annotation.subtitle = "\(placemark.administrativeArea ?? ""), \(placemark.locality ?? ""), \(placemark.isoCountryCode ?? "")"
            uiView.addAnnotation(annotation)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView

        init(_ parent: CustomMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
            annotationView.canShowCallout = true
            return annotationView
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
