import SwiftUI
import RichTextKit

// Represents a journal entry with a unique identifier, date, title, and body.
struct Entry: Identifiable {
    var id = UUID()
    var date: Date
    var title: String
    var bodyData: Data
}

// Main view for displaying and managing journal entries.
struct ContentView: View {
    @State private var entries: [Entry] = [] // Holds the list of entries.
    @State private var selectedDate: Date = Date() // Tracks the selected date.
    @State private var searchText = "" // Holds the search text.
    @State private var sortingPreference: SortingPreference = .latest // Tracks the sorting preference.
    @State private var showingSettings = false

    init() {
      // Large Navigation Title
      UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.black]
      // Inline Navigation Title
      UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color for the view.
                Color(red: 0.960, green: 0.910, blue: 0.780)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    // Search bar for filtering entries.
                    TextField("", text: $searchText)
                        .modifier(PlaceholderStyle(showPlaceholder: searchText.isEmpty, placeholder: "Search by date or title"))
                        .padding(7)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    // List of filtered entries.
                    List(filteredEntries) { entry in
                        NavigationLink(destination: NewPageView(entry: entry, isNewEntry: false, saveAction: saveEntry)) {
                            VStack(alignment: .leading) {
                                Text("\(entry.date, style: .date)")
                                    .font(.subheadline)
                                Text(entry.title)
                                    .font(.headline)
                            }
                        }
                        .contextMenu {
                            Button(action: {
                                // Add code to delete the entry
                                deleteEntry(entry: entry)
                            }) {
                                Text("Delete")
                                Image(systemName: "trash")
                            }
                        }
                    }
                    Spacer()

                    // Buttons for calendar view and adding a new entry.
                    HStack {
                        // Button to open calendar view.
                        NavigationLink(destination: CalendarAndEntriesView(entries: $entries, selectedDate: selectedDate, saveAction: saveEntry)) {
                            Image(systemName: "calendar")
                                .foregroundColor(.white)
                                .font(.title)
                                .padding()
                                .background(Circle().fill(Color.blue))
                                .shadow(radius: 10)
                        }
                        
                        Spacer()
                        
                        // Button to add a new entry.
                        NavigationLink(destination: NewPageView(entry: Entry(date: Date(), title: "", bodyData: Data()), isNewEntry: true, saveAction: addEntry)) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.title)
                                .padding()
                                .background(Circle().fill(Color.blue))
                                .shadow(radius: 10)
                        }
                    }
                    .padding(.horizontal)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gear")
                        }
                    }
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView().environmentObject(UserSettings.shared)
                }
                .navigationTitle(Text("Entries"))//.minimumScaleFactor(0.5).lineLimit(1)
                .navigationBarItems(trailing: Button(action: {
                    // Toggle sorting preference between latest and oldest.
                    toggleSortingPreference()
                }) {
                    Image(systemName: "arrow.up.arrow.down")
                    Text(sortingPreference == .latest ? "Latest" : "Oldest")
                    .font(.custom("NewYork", size: 22))
                })
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView().environmentObject(UserSettings.shared)
        }

        // Filters and sorts entries based on user input and preferences.
        var filteredEntries: [Entry] {
            var sortedEntries = entries
            sortedEntries.sort {
                sortingPreference == .latest ? $0.date > $1.date : $0.date < $1.date
            }

            if searchText.isEmpty { return sortedEntries }

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none

            return sortedEntries.filter { entry in
                let dateString = dateFormatter.string(from: entry.date)
                let titleLowercased = entry.title.lowercased()
                let searchTextLowercased = searchText.lowercased()

                return dateString.lowercased().contains(searchTextLowercased) || titleLowercased.contains(searchTextLowercased)
            }
        }
    }
    
    func deleteEntry(entry: Entry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries.remove(at: index)
        }
    }
    
    // Toggles the sorting preference between latest and oldest.
    func toggleSortingPreference() {
        sortingPreference = (sortingPreference == .latest) ? .oldest : .latest
    }
    
    // Enum to define sorting preferences.
    enum SortingPreference {
        case latest
        case oldest
    }

    // Adds a new entry to the journal.
    func addEntry(entry: Entry) {
        entries.append(entry)
    }
    
    // Updates an existing entry or adds a new one if not found.
    func saveEntry(updatedEntry: Entry) {
        if let index = entries.firstIndex(where: { $0.id == updatedEntry.id }) {
            entries[index] = updatedEntry
        } else {
            entries.append(updatedEntry)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
