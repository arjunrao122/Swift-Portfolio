import SwiftUI

struct PasswordEntryView: View {
    // State variable to store the entered password
    @State private var enteredPassword: String = ""
    
    // Accessing UserSettings for password verification
    @EnvironmentObject var userSettings: UserSettings
    
    // State variable to control navigation to ContentView
    @State private var showContentView = false
    
    // State variable to show error message for incorrect password
    @State private var showError = false

    var body: some View {
        if showContentView {
            ContentView() // Navigate to ContentView if password is correct
        } else {
            VStack(spacing: 20) {
                Text("Welcome Back!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.blue)

                Text("Please enter your password to continue.")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                SecureField("Password", text: $enteredPassword)
                    .textFieldStyle(CustomTextFieldStyle()) // Custom style for the password field

                // Display error message if the password is incorrect
                if showError {
                    Text("Incorrect password. Please try again.")
                        .font(.caption)
                        .foregroundColor(.red)
                }

                // Button to verify the password
                Button(action: {
                    if enteredPassword == userSettings.password {
                        showContentView = true // Correct password
                    } else {
                        enteredPassword = "" // Reset entered password
                        showError = true // Show error message
                    }
                }) {
                    Text("Enter")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .font(.title)
                        .padding()
                        .foregroundColor(.white)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(40)
                        .padding(.horizontal, 20)
                }
                .disabled(enteredPassword.isEmpty) // Disable button if no password is entered
            }
            .padding()
        }
    }
}
