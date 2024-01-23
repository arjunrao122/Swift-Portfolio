import SwiftUI

// A custom view for presenting content in a modal that covers half the screen.
struct HalfModalView<Content: View>: View {
    @Binding var isShown: Bool // Binding to control the visibility of the modal.
    var modalHeight: CGFloat // The height of the modal view.
    let content: Content // The content to be displayed in the modal.

    // Custom initializer for the HalfModalView.
    init(isShown: Binding<Bool>, modalHeight: CGFloat, @ViewBuilder content: () -> Content) {
        self._isShown = isShown
        self.modalHeight = modalHeight
        self.content = content() // Content view builder.
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer() // Creates space at the top, pushing the modal down.
                VStack {
                    self.content // The content passed into the modal.
                }
                .frame(width: geometry.size.width, height: self.modalHeight) // Sets the frame of the modal.
                .background(Color.white) // Background color of the modal.
                .cornerRadius(10) // Rounded corners for the modal.
                .shadow(radius: 5) // Shadow for a floating effect.
                .transition(.move(edge: .bottom)) // Transition effect for the modal presentation.
                .animation(.easeOut(duration: 0.3), value: isShown) // Animation for the modal's appearance and disappearance.
            }
        }
        .edgesIgnoringSafeArea(.all) // Ensures the modal and background cover the entire screen.
        .background(
            Color.black.opacity(0.5) // Semi-transparent background when the modal is shown.
                .edgesIgnoringSafeArea(.all) // Extends the background to the edges of the screen.
                .opacity(self.isShown ? 1 : 0) // Controls the opacity based on whether the modal is shown.
                .animation(.easeOut(duration: 0.3), value: isShown) // Animation for the background fade in and out.
        )
    }
}
