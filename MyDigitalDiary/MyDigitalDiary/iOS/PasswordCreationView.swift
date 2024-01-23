import SwiftUI

struct PasswordCreationView: View {
    // State variables to store user inputs
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    // State variable to navigate to ContentView after successful account creation
    @State private var showContentView = false
    
    // Environment object for accessing shared user settings
    @EnvironmentObject var userSettings: UserSettings
    
    // State variables for displaying an error alert
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        if showContentView {
            ContentView() // Transition to ContentView when account creation is successful
        } else {
            VStack(spacing: 20) {
                Text("Create Your Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.blue)

                // Input field for username
                TextField("Username", text: $username)
                    .textFieldStyle(CustomTextFieldStyle())

                // Input fields for password and password confirmation
                SecureField("Set Password", text: $password)
                    .textFieldStyle(CustomTextFieldStyle())
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(CustomTextFieldStyle())

                // Save button with validation logic
                Button(action: {
                    if validateInputs() {
                        userSettings.password = password
                        userSettings.isFirstLaunch = false
                        showContentView = true
                    } else {
                        showErrorAlert = true
                    }
                }) {
                    Text("Save")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .font(.title)
                        .padding()
                        .foregroundColor(.white)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(40)
                        .padding(.horizontal, 20)
                }
                .disabled(username.isEmpty || password.isEmpty || confirmPassword.isEmpty)
            }
            .padding()
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    // Function to validate user inputs
    private func validateInputs() -> Bool {
        if password != confirmPassword {
            errorMessage = "Passwords do not match."
            return false
        }
        // Additional validation logic can be added here
        return true
    }
}

// Custom TextField style to enhance UI aesthetics
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(15)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 0)
    }
}
