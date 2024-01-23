import RichTextKit
import SwiftUI

// A view for rich text editing using RichTextKit.
struct EditorScreen: View {

    @State
    private var text = NSAttributedString.empty // State to hold the rich text content.

    @StateObject
    var context = RichTextContext() // State object for rich text editing context.

    var body: some View {
        VStack {
            editor.padding() // The rich text editor view with padding.
            toolbar // The toolbar associated with the rich text editor.
        }
        .background(Color.primary.opacity(0.15)) // Background color for the editor screen.
        .navigationTitle("RichTextKit") // Navigation bar title.
        .toolbar {
            // Toolbar items for additional functionality or navigation.
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                MainMenu()
            }
        }
        .viewDebug() // Debug view, useful during development.
    }
}

// Private extension to organize the subviews of the editor screen.
private extension EditorScreen {

    // The rich text editor view.
    var editor: some View {
        RichTextEditor(text: $text, context: context) {
            $0.textContentInset = CGSize(width: 10, height: 20) // Content inset for the editor.
        }
        .background(Material.regular) // Background material for the editor.
        .cornerRadius(5) // Corner radius for the editor's background.
        .focusedValue(\.richTextContext, context) // Focus management for the rich text editor.
    }

    // The toolbar view for the rich text editor.
    var toolbar: some View {
        RichTextKeyboardToolbar(
            context: context,
            leadingButtons: {}, // Leading buttons, currently empty.
            trailingButtons: {} // Trailing buttons, currently empty.
        )
    }
}

// Preview provider for EditorScreen.
struct EditorScreen_Previews: PreviewProvider {
    
    static var previews: some View {
        EditorScreen()
    }
}
