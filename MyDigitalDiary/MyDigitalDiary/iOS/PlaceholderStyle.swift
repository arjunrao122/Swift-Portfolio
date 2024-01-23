import SwiftUI

// A ViewModifier to add placeholder text to SwiftUI views like TextFields.
struct PlaceholderStyle: ViewModifier {
    var showPlaceholder: Bool // Determines whether the placeholder should be visible.
    var placeholder: String // The placeholder text to display.

    // The body function that defines the modification to the view.
    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            // Conditionally display the placeholder text.
            if showPlaceholder {
                Text(placeholder)
                    .foregroundColor(.black) // Placeholder text color set to black for visibility.
            }
            // The original content of the view.
            content
        }
    }
}
