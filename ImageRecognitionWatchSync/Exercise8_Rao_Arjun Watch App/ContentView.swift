import WatchConnectivity
import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var provider = ConnectivityProvider.shared

    var body: some View {
        VStack {
            Text("Pª ")
                .foregroundStyle(.red)
                .font(.system(size: 36))
                .bold()
                .frame(maxWidth: .infinity, alignment: .trailing)
            Text(provider.receivedEmoji)
                .font(.system(size: 80))
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100)
        }
    }
}

class ConnectivityProvider: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = ConnectivityProvider()
    @Published var receivedEmoji: String = "❓"

    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let emoji = message["emoji"] as? String {
            DispatchQueue.main.async {
                self.receivedEmoji = emoji
            }
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle session activation completion
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
