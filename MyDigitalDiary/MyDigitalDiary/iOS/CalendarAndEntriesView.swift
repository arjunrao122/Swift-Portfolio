import SwiftUI

// Main view that displays the calendar and a list of entries.
struct CalendarAndEntriesView: View {
    @Binding var entries: [Entry] // The entries to display in the calendar.
    @State var selectedDate: Date = Date() // The currently selected date.
    @Environment(\.presentationMode) var presentationMode // For managing the view's presentation state.
    let saveAction: (Entry) -> Void // Action to save an entry.

    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.verticalSizeClass) var vSizeClass
    
    var body: some View {
//        if (hSizeClass == .compact && vSizeClass == .regular) || (hSizeClass == .regular && vSizeClass == .regular) { // portrait or ipad
        if hSizeClass == .compact && vSizeClass == .regular { // portrait
            VStack {
                // Custom calendar view with entries and navigation.
                CustomCalendarView(entries: $entries, selectedDate: $selectedDate)
                    .padding()
                
                // List of entries filtered by the selected date.
                List(filteredEntries()) { entry in
                    NavigationLink(destination: NewPageView(entry: entry, isNewEntry: false, saveAction: saveAction)) {
                        VStack(alignment: .leading) {
                            Text("\(entry.date, style: .date)")
                                .font(.subheadline)
                            Text(entry.title)
                                .font(.headline)
                        }
                    }
                }
            }
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        } else if hSizeClass == .regular && vSizeClass == .regular {
            VStack {
                // Custom calendar view with entries and navigation.
                CustomCalendarView(entries: $entries, selectedDate: $selectedDate)
                    .padding()
                    .frame(width: 750)
                
                // List of entries filtered by the selected date.
                List(filteredEntries()) { entry in
                    NavigationLink(destination: NewPageView(entry: entry, isNewEntry: false, saveAction: saveAction)) {
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
                }            }
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        } else { //if hSizeClass == .regular && vSizeClass == .compact { // landscape
            HStack {
                // Custom calendar view with entries and navigation.
                CustomCalendarView(entries: $entries, selectedDate: $selectedDate)
                    .padding()
                    .frame(width: 350)
                
                // List of entries filtered by the selected date.
                List(filteredEntries()) { entry in
                    NavigationLink(destination: NewPageView(entry: entry, isNewEntry: false, saveAction: saveAction)) {
                        VStack(alignment: .leading) {
                            Text("\(entry.date, style: .date)")
                                .font(.subheadline)
                            Text(entry.title)
                                .font(.headline)
                        }
                    }
                }
            }
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    func deleteEntry(entry: Entry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries.remove(at: index)
        }
    }

    // Filters the entries by the selected date.
    func filteredEntries() -> [Entry] {
        entries.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    // DateFormatter for displaying dates.
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
}

// Custom view for displaying a calendar with entries.
struct CustomCalendarView: View {
    @Binding var entries: [Entry]
    @Binding var selectedDate: Date
    
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.verticalSizeClass) var vSizeClass
    

    let calendar = Calendar.current // Calendar instance for date calculations.
    let today = Date() // Today's date.

    // Computes the start of the month for the selected date.
    var month: Date {
        calendar.startOfMonth(for: selectedDate)
    }

    var body: some View {
        VStack {
            // Navigation for changing months.
            HStack {
                monthNavigationButton(systemName: "chevron.left", action: { self.changeMonth(by: -1) }, buttonColor: .gray)
                Spacer()
                
//                if (hSizeClass == .compact && vSizeClass == .regular) || (hSizeClass == .regular && vSizeClass == .regular) { // portrait or ipad
                if (hSizeClass == .compact && vSizeClass == .regular) { // portrait
                    Text("\(month, formatter: monthYearFormatter)")
                        .font(.headline)
                        .foregroundColor(.white)
                } else if (hSizeClass == .regular && vSizeClass == .regular) { // ipad
                    Text("\(month, formatter: monthYearFormatter)")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                } else { //if hSizeClass == .regular && vSizeClass == .compact { // landscape
                    Text("\(month, formatter: monthYearFormatter)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                monthNavigationButton(systemName: "chevron.right", action: { self.changeMonth(by: 1) }, buttonColor: .gray)
            }
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.horizontal)

            // Weekday headers displayed at the top of the calendar.
            HStack(spacing: 0) {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { weekday in
                    if hSizeClass == .regular && vSizeClass == .regular { // ipad
                        Text(weekday)
                            .font(.headline)
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                    } else {
                        Text(weekday)
                            .font(.caption)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                    }
                }
            }

            // Grid of days in the month.
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(daysInMonth(), id: \.self) { day in
                    VStack {
                        // Only display days that are in the same month.
                        if hSizeClass == .regular && vSizeClass == .compact { // landscape
                            if calendar.isDate(day, inSameMonthAs: month) {
                                Text("\(day, formatter: dateFormatter)")
                                    .fontWeight(calendar.isDate(day, inSameDayAs: today) ? .bold : .regular)
                                    .foregroundColor(.black)
                                    .padding(5)
                                    .background(hasEntry(for: day) ? Color.green.opacity(0.6) : Color.white)
                                    .cornerRadius(8)
                            }
                        } else if hSizeClass == .regular && vSizeClass == .regular { // ipad
                            if calendar.isDate(day, inSameMonthAs: month) {
                                Text("\(day, formatter: dateFormatter)")
                                    .fontWeight(calendar.isDate(day, inSameDayAs: today) ? .bold : .regular)
                                    .foregroundColor(.black)
                                    .padding(15)
                                    .background(hasEntry(for: day) ? Color.green.opacity(0.6) : Color.white)
                                    .cornerRadius(8)
                            }
                        } else { // if hSizeClass == .compact && vSizeClass == .regular { // portrait
                            if calendar.isDate(day, inSameMonthAs: month) {
                                Text("\(day, formatter: dateFormatter)")
                                    .fontWeight(calendar.isDate(day, inSameDayAs: today) ? .bold : .regular)
                                    .foregroundColor(.black)
                                    .padding(8)
                                    .background(hasEntry(for: day) ? Color.green.opacity(0.6) : Color.white)
                                    .cornerRadius(8)
                            }
                        }
                        
                    }
                    .onTapGesture {
                        self.selectedDate = day
                    }
                }
            }
        }
        .background(Color(UIColor.systemGray6))
        .cornerRadius(15)

    }
    
    func monthNavigationButton(systemName: String, action: @escaping () -> Void, buttonColor: Color) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .foregroundColor(.white)
                .padding()
                .background(buttonColor)
                .clipShape(Circle())
                .shadow(radius: 3)
        }
    }

    func daysInMonth() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else { return [] }
        return calendar.generateDays(for: monthInterval)
    }

    func hasEntry(for date: Date) -> Bool {
        entries.contains { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    func changeMonth(by amount: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: amount, to: month) {
            selectedDate = newMonth
        }
    }

    var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components)!
    }

    func generateDays(for interval: DateInterval) -> [Date] {
        var days: [Date] = []
        var day = interval.start

        while day <= interval.end {
            days.append(day)
            if let nextDay = self.date(byAdding: .day, value: 1, to: day) {
                day = nextDay
            } else {
                break
            }
        }

        return days
    }

    func isDate(_ date1: Date, inSameMonthAs date2: Date) -> Bool {
        let components1 = dateComponents([.year, .month], from: date1)
        let components2 = dateComponents([.year, .month], from: date2)
        return components1.year == components2.year && components1.month == components2.month
    }
}

