import SwiftUI
import RichTextKit

// View for creating or editing a journal entry.
struct NewPageView: View {
    @Environment(\.presentationMode) var presentationMode // Environment property to control the presentation mode.
    @State private var selectedDate = Date() // The date for the entry.
    @State private var tempSelectedDate = Date() // Temporary storage for the selected date.
    @State private var titleText = "" // Title of the entry.
    @State private var bodyAttributedText = NSAttributedString(string: "") // Rich text content of the entry.
    @State private var showingDatePicker = false // State to control the visibility of the date picker.
    @StateObject private var richTextContext = RichTextContext() // Context for rich text editor.
    var isNewEntry: Bool // Flag to check if it's a new entry or an edit.
    let saveAction: (Entry) -> Void // Closure to handle saving the entry.
    var entry: Entry // The entry being edited or created.

    // Custom initializer to set up the view with an entry.
    init(entry: Entry, isNewEntry: Bool, saveAction: @escaping (Entry) -> Void) {
        _selectedDate = State(initialValue: entry.date)
        _titleText = State(initialValue: entry.title)
        // Attempt to convert bodyData to NSAttributedString.
        if let attributedString = try? NSAttributedString(data: entry.bodyData, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil) {
            _bodyAttributedText = State(initialValue: attributedString)
        } else {
            _bodyAttributedText = State(initialValue: NSAttributedString(string: ""))
        }
        self.entry = entry
        self.isNewEntry = isNewEntry
        self.saveAction = saveAction
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        ZStack {
            // Background color for the view.
            Color(red: 54.0 / 255.0, green: 48.0 / 255.0, blue: 98.0 / 255.0)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) {
                // Displays the selected date and opens the date picker on tap.
                HStack {
                    Text(selectedDate, style: .date)
                        .foregroundColor(.white)
                    Image(systemName: "chevron.down")
                        .foregroundColor(.white)
                }
                .onTapGesture {
                    self.tempSelectedDate = self.selectedDate
                    self.showingDatePicker = true
                }
                .padding()

                // Title text field.
                ZStack(alignment: .leading) {
                    if titleText.isEmpty {
                        Text("Enter Title")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.8))
                            .font(.custom("NewYork", size: 22))
                    }
                    TextField("", text: $titleText)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                // Rich text editor for the body of the entry.
                richTextEditor
                // Toolbar for the rich text editor.
                toolbar
            }
            .padding()

            // Date picker modal view.
            if showingDatePicker {
                HalfModalView(isShown: $showingDatePicker, modalHeight: UIScreen.main.bounds.height / 3) {
                    VStack {
                        HStack {
                            Button("Cancel") {
                                self.showingDatePicker = false
                            }
                            Spacer()
                            Button("Done") {
                                self.selectedDate = self.tempSelectedDate
                                self.showingDatePicker = false
                            }
                        }
                        .padding()
                        
                        DatePicker(
                            "Select a date",
                            selection: $tempSelectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                    }
                }
            }
        }
        // Navigation bar configuration.
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Entries")
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .navigationBarItems(trailing: Button(action: {
            // Save button action.
            saveData()
            // Dismiss the view after saving.
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Text("Done")
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.green)
                .cornerRadius(20)
                .bold()
        })
        .navigationBarTitle("Add Entry")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Subview for rich text editor.
    private var richTextEditor: some View {
        RichTextEditor(text: $bodyAttributedText, context: richTextContext) {
            $0.textContentInset = CGSize(width: 10, height: 20)
        }
        .background(Color(red: 129 / 255.0, green: 143 / 255.0, blue: 180 / 255.0))
        .cornerRadius(5)
        .focusedValue(\.richTextContext, richTextContext)
    }

    // Subview for the toolbar associated with the rich text editor.
    private var toolbar: some View {
        RichTextKeyboardToolbar(
            context: richTextContext,
            leadingButtons: {},
            trailingButtons: {}
        )
    }

    // Function to save the data of the entry.
    func saveData() {
        do {
            let bodyData = try bodyAttributedText.data(from: NSRange(location: 0, length: bodyAttributedText.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
            let updatedEntry = Entry(id: entry.id, date: selectedDate, title: titleText, bodyData: bodyData)
            saveAction(updatedEntry)
        } catch {
            print("Error converting NSAttributedString to Data: \(error)")
        }
    }
}
