import SwiftUI

struct SplashScreenView: View {
    @State var isActive: Bool = false
    @EnvironmentObject var userSettings: UserSettings
    
    @State private var size = 0.8
    @State private var opacity = 0.5

    var body: some View {
        if isActive {
            if userSettings.isFirstLaunch {
                PasswordCreationView()
            } else {
                PasswordEntryView()
            }
        } else {
            VStack {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                Text("Keep a diary,")
                    .font(Font.custom("Baskerville-Bold", size: 26))
                    .foregroundColor(.black.opacity(0.80))
                Text("and someday it'll keep you.")
                    .font(Font.custom("Baskerville-Bold", size: 26))
                    .foregroundColor(.black.opacity(0.80))
            }
            .scaleEffect(size)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 1.2)) {
                    self.size = 1.00
                    self.opacity = 1.00
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}
