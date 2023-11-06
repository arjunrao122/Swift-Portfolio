import SwiftUI
import MapKit
import CoreLocation

struct Treasure: Identifiable, Decodable {
    let id: Int
    let type: String
    let owner: String
    let value: Int
    let cap_lat: Double
    let cap_long: Double
    let hint: String
}

struct ContentView: View {
    @State private var searchText: String = "" {
        didSet {
            filterTreasures()
        }
    }

    @State private var filteredTreasures: [Treasure] = []
    @State private var treasures: [Treasure] = [] {
        didSet {
            filteredTreasures = treasures
        }
    }

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack {
                    TextField("Search by ID, Type, or Owner", text: $searchText, onCommit: filterTreasures)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    List {
                        ForEach(filteredTreasures) { treasure in
                            NavigationLink(destination: CustomMapView(treasure: treasure)) {
                                EmptyView()
                            }
                            .opacity(0)
                            .overlay(
                                ZStack {
                                    VStack {
                                        Spacer()
                                        Text("\(treasure.type) # \(treasure.id)")
                                            .font(.headline)
                                        Text("\(treasure.owner)")
                                            .font(.subheadline)
                                        Spacer()
                                    }
                                    .padding(13)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(getBackgroundColor(for: treasure.value))
                                }
                            )
                            .buttonStyle(PlainButtonStyle())
                            .frame(minHeight: 80)
                            .listRowInsets(EdgeInsets())
                        }
                        .onDelete(perform: deleteTreasure)
                    }
                    .listStyle(PlainListStyle())
                    .onAppear {
                        fetchTreasures()
                    }
                }
            }
            .padding(geometry.size.width > geometry.size.height ? 1 : 0)
        }
    }

    func filterTreasures() {
        if searchText.isEmpty {
            filteredTreasures = treasures
        } else {
            filteredTreasures = treasures.filter {
                "\($0.id)".contains(searchText) ||
                $0.type.lowercased().contains(searchText.lowercased()) ||
                $0.owner.lowercased().contains(searchText.lowercased())
            }
        }
    }

    func deleteTreasure(at offsets: IndexSet) {
        treasures.remove(atOffsets: offsets)
    }

    func fetchTreasures() {
        guard let url = URL(string: "https://m.cpl.uh.edu/courses/ubicomp/fall2022/webservice/treasures.json") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode([Treasure].self, from: data)
                    DispatchQueue.main.async {
                        treasures = decodedData
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }

    func getBackgroundColor(for value: Int) -> Color {
        switch value {
        case 100:
            return Color(red: 255/255, green: 215/255, blue: 0/255)
        case 80:
            return Color(red: 255/255, green: 245/255, blue: 0/255)
        case 50:
            return Color(red: 255/255, green: 255/255, blue: 204/255)
        default:
            return Color.clear
        }
    }
}

struct CustomMapView: UIViewRepresentable {
    var treasure: Treasure
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.addAnnotation(gesture:)))
        longPressGesture.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(longPressGesture)

        return mapView
    }

    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let coordinate = CLLocationCoordinate2D(latitude: treasure.cap_lat, longitude: treasure.cap_long)
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        uiView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = treasure.hint
        
        let location = CLLocation(latitude: treasure.cap_lat, longitude: treasure.cap_long)
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
        var pinCounter: Int = 0

        init(_ parent: CustomMapView) {
            self.parent = parent
        }

        @objc func addAnnotation(gesture: UILongPressGestureRecognizer) {
            if gesture.state == .began {
                let touchPoint = gesture.location(in: gesture.view)
                guard let mapView = gesture.view as? MKMapView else { return }
                let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = touchMapCoordinate

                self.pinCounter += 1
                annotation.title = "Pin #\(self.pinCounter)"
                annotation.subtitle = "Unique Marker \(self.pinCounter)"

                mapView.addAnnotation(annotation)
            }
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
