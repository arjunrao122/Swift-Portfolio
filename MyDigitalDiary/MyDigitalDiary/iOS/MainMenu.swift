import SwiftUI
import RichTextKit

// A view representing the main menu for additional actions and navigation.
struct MainMenu: View {

    @State
    private var isSheetPresented = false // State to control the presentation of a modal view.

    var body: some View {
        Menu {
            // Menu for sharing in various formats.
            RichTextShareMenu(
                formats: .libraryFormats, // Specifies the formats available for sharing.
                formatAction: { print("TODO: Share file for \($0.id)") }, // Action for sharing in a specific format.
                pdfAction: { print("TODO: Share PDF file") }) // Action for sharing as PDF.
            // Menu for exporting in various formats.
            RichTextExportMenu(
                formats: .libraryFormats, // Specifies the formats available for export.
                formatAction: { print("TODO: Export file for \($0.id)") }, // Action for exporting in a specific format.
                pdfAction: { print("TODO: Export PDF file") }) // Action for exporting as PDF.
            Divider() // Visual separator.
            // Links to additional screens or information.
            link(to: .about) // Link to the 'About' screen.
            webLink(to: .github) // Link to the GitHub page.
            webLink(to: .documentation) // Link to the documentation.
        } label: {
            Image.menu // Icon for the menu.
        }.sheet(isPresented: $isSheetPresented) {
            // Sheet that presents the 'About' screen.
            NavigationView {
                AboutScreen(showTitle: false)
            }.navigationViewStyle(.stack)
        }
    }
}

// Extension of MainMenu to organize helper functions for creating links.
extension MainMenu {

    // Creates a button that opens a modal view.
    func link(to screen: DemoScreen) -> some View {
        Button(action: { isSheetPresented = true }) {
            screen.label // Label for the button.
        }
    }

    // Creates a link to an external webpage.
    func webLink(to url: DemoUrl) -> some View {
        Link(destination: url.url) { // URL for the link.
            url.label // Label for the link.
        }
    }
}

// Preview provider for MainMenu.
struct MainMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu()
    }
}
