import SwiftUI

struct SettingsView: View {
    // Environment object for accessing user settings
    @EnvironmentObject var userSettings: UserSettings

    // State variables for user inputs
    @State private var newUsername: String
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    // State variables for alerts
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSuccessAlert = false

    // Initialize with a default empty username
    init() {
        _newUsername = State(initialValue: "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Details").foregroundColor(.blue).font(.headline)) {
                    // Text field for entering a new username
                    TextField("New Username", text: $newUsername)
                        .textFieldStyle(CustomTextFieldStyle())

                    // Secure fields for entering and confirming a new password
                    SecureField("New Password", text: $newPassword)
                        .textFieldStyle(CustomTextFieldStyle())
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(CustomTextFieldStyle())

                    // Display an error message if passwords do not match
                    if !confirmPassword.isEmpty && newPassword != confirmPassword {
                        Text("Passwords do not match.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                // Button to save changes with custom style
                Button("Save Changes", action: saveChanges)
                    .buttonStyle(CustomButtonStyle())
                    .disabled(newUsername.isEmpty || (newPassword.isEmpty != confirmPassword.isEmpty))
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .onAppear {
                // Set initial username value when the view appears
                self.newUsername = self.userSettings.username
            }
            // Alerts for error and success messages
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showSuccessAlert) {
                Alert(title: Text("Success"), message: Text("Your settings have been updated."), dismissButton: .default(Text("OK")))
            }
        }
    }

    // Function to handle saving changes
    private func saveChanges() {
        var isUpdated = false

        // Update username if it has changed
        if !newUsername.isEmpty && newUsername != userSettings.username {
            userSettings.updateUsername(newUsername: newUsername)
            isUpdated = true
        }

        // Update password if it's entered and confirmed
        if !newPassword.isEmpty && newPassword == confirmPassword {
            userSettings.updatePassword(newPassword: newPassword)
            isUpdated = true
        } else if newPassword != confirmPassword {
            // Show alert if passwords do not match
            alertMessage = "Passwords do not match."
            showAlert = true
            return
        }

        // Show success alert if any changes were made
        if isUpdated {
            showSuccessAlert = true
        }
    }
}

// Custom style for buttons in SettingsView
struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(10)
            .padding(.horizontal)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Slightly scale down on press
    }
}
