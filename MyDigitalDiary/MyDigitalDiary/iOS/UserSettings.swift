import SwiftUI

class UserSettings: ObservableObject {
    // Singleton instance for global access
    static let shared = UserSettings()

    // UserDefaults to store user settings
    private let defaults = UserDefaults.standard

    // Keys for storing data in UserDefaults
    private let passwordKey = "userPassword"
    private let usernameKey = "username"

    // Published username property to trigger UI updates on change
    @Published var username: String {
        didSet {
            // Update the username in UserDefaults when changed
            updateUsername(newUsername: username)
        }
    }

    // Initialize the UserSettings object
    init() {
        // Load the stored username from UserDefaults or use a default value if not set
        username = defaults.string(forKey: usernameKey) ?? ""
    }

    // Property to determine if the app is launched for the first time
    var isFirstLaunch: Bool {
        get {
            return !defaults.bool(forKey: "hasLaunchedBefore")
        }
        set {
            // Store the launch status in UserDefaults
            defaults.set(!newValue, forKey: "hasLaunchedBefore")
        }
    }

    // Property to get and set the user's password
    var password: String? {
        get {
            // Retrieve the password from UserDefaults
            return defaults.string(forKey: passwordKey)
        }
        set {
            // Store the password in UserDefaults
            defaults.set(newValue, forKey: passwordKey)
        }
    }

    // Function to update the username in UserDefaults
    func updateUsername(newUsername: String) {
        defaults.set(newUsername, forKey: usernameKey)
    }

    // Function to update the password in UserDefaults
    func updatePassword(newPassword: String) {
        defaults.set(newPassword, forKey: passwordKey)
    }
}
