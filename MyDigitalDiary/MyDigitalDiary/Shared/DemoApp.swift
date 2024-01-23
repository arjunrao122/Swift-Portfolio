import SwiftUI
import RichTextKit

@main
struct DemoApp: App {
    @StateObject var userSettings = UserSettings.shared

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(userSettings)
        }
    }
}
