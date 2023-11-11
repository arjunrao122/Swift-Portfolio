import SwiftUI
import Vision
import CoreML
import WatchConnectivity

class ConnectivityProvider: NSObject, WCSessionDelegate {
    static let shared = ConnectivityProvider()

    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func sendEmojiToWatch(_ emoji: String) {
        if WCSession.default.isReachable {
            let message = ["emoji": emoji]
            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }

    // WCSessionDelegate required methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Handle session activation completion
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        // Handle session becoming inactive
    }

    func sessionDidDeactivate(_ session: WCSession) {
        // Handle session deactivation
        WCSession.default.activate() // You might want to reactivate the session
    }
}



struct ContentView: View {
    @State private var identifiedObjects: [(object: String, confidence: Double)] = []
    @State private var recognizedText: String = ""
    @State private var currentImageName = "car"
    @State private var isTextRecognitionActive = false
    private let imageNames = ["car", "house", "people"]
    @State private var showImagePicker: Bool = false
    @State private var inputImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        TabView {
            VStack {
                Text("What?!")
                    .foregroundStyle(.white)
                    .font(.system(size: 36))
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .trailing)

                if let inputImage = inputImage {
                                Image(uiImage: inputImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 350, height: 350)
                                    .border(.red, width: 4)
                } else {Image(currentImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350, height: 350)
                        .border(.red, width: 4)
                        .onTapGesture {
                            switchImage()
                        }
                        .onAppear {
                            identifyObjects(from: .name(currentImageName))
                            sendEmojiForCurrentImage()
                        }
                }

                Spacer()

                HStack(alignment: .center) {
                    Text("Objects:")
                        .font(.headline)
                        .frame(minWidth: 80, alignment: .leading)
                        .foregroundColor(.red)

                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(identifiedObjects.prefix(7), id: \.object) { item in
                            Text("Confidence \(String(format: "%.2f%%", item.confidence * 100)) - \(item.object)")
                                .foregroundColor(.red)
                                .font(.system(size: 12))
                        }
                    }
                }
                HStack{
                    Button("Choose Photo") {
                        self.sourceType = .photoLibrary
                        self.showImagePicker = true
                    }
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    Button("Take Photo") {
                        self.sourceType = .camera
                        self.showImagePicker = true
                    }
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    .sheet(isPresented: $showImagePicker, onDismiss: loadImage) {
                        ImagePicker(selectedImage: self.$inputImage, sourceType: self.sourceType)
                    }
                    .padding()
                }
                Spacer()
            }
            .tabItem {
                Image(systemName: "photo")
                Text("Object Identification")
            }
            
            VStack {
                Spacer()
                if let inputImage = inputImage {
                                Image(uiImage: inputImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 350, height: 350)
                                    .border(.red, width: 4)
                } else {Image(currentImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350, height: 350)
                        .border(.red, width: 4)
                        .onTapGesture {
                            switchImage()
                        }
                }
                Spacer()

                if !recognizedText.isEmpty {
                    Spacer()
                    HStack {
                        Text("Text:")
                            .font(.headline)
                            .frame(minWidth: 10, alignment: .leading)
                            .foregroundColor(.red)
                        Text(recognizedText)
                            .padding()
                            .foregroundColor(.red)
                            .background(Color.white)
                            .cornerRadius(5)
                    }
                    Spacer()
                } else {
                    Spacer()
                    Text("Recognizing text...")
                        .foregroundColor(.red)
                    Spacer()
                }
                HStack{
                    Button("Choose Photo") {
                        self.sourceType = .photoLibrary
                        self.showImagePicker = true
                    }
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    Button("Take Photo") {
                        self.sourceType = .camera
                        self.showImagePicker = true
                    }
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    .sheet(isPresented: $showImagePicker, onDismiss: loadImage) {
                        ImagePicker(selectedImage: self.$inputImage, sourceType: self.sourceType)
                    }
                    .padding()
                }
            }
            .tabItem {
                Image(systemName: "text.bubble")
                Text("Text Recognition")
            }
            .onAppear {
                performTextRecognition(from: .name(currentImageName))
                sendEmojiForCurrentImage()
            }
        }
        .accentColor(.red)
        .overlay(
            PaLabel().padding([.top, .trailing]),
            alignment: .topTrailing
        )
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        identifyObjects(from: .image(inputImage))
        performTextRecognition(from: .image(inputImage))
        }
    
    private func sendEmojiForCurrentImage() {
            let emoji = emojiForImage(currentImageName)
            ConnectivityProvider.shared.sendEmojiToWatch(emoji)
        }
    
    private func switchImage() {
        currentImageName = imageNames.filter { $0 != currentImageName }.randomElement() ?? currentImageName
        identifyObjects(from: .name(currentImageName))
        performTextRecognition(from: .name(currentImageName))

        let emoji = emojiForImage(currentImageName)
        ConnectivityProvider.shared.sendEmojiToWatch(emoji)
    }

    private func emojiForImage(_ imageName: String) -> String {
        switch imageName {
        case "car":
            return "🚗"
        case "house":
            return "🏠"
        case "people":
            return "💻"
        default:
            return "❓"
        }
    }
    private func performTextRecognition(from imageSource: ImageSource) {
        let cgImage: CGImage?

        switch imageSource {
        case .name(let imageName):
            guard let uiImage = UIImage(named: imageName) else {
                print("Failed to load UIImage from name")
                return
            }
            cgImage = uiImage.cgImage
        case .image(let uiImage):
            cgImage = uiImage.cgImage
        }

        guard let cgImage = cgImage else {
            print("Unable to create CGImage")
            return
        }

        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                DispatchQueue.main.async {
                    self.recognizedText = "Text recognition error."
                }
                return
            }
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }

            DispatchQueue.main.async {
                self.recognizedText = recognizedStrings.joined(separator: "\n")
            }
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform text recognition: \(error)")
            }
        }
    }
    
    private func identifyObjects(from imageSource: ImageSource) {
        let configuration = MLModelConfiguration()
        guard let model = try? VNCoreMLModel(for: Resnet50(configuration: configuration).model) else {
            print("Failed to load the model")
            return
        }

        let ciImage: CIImage?
        switch imageSource {
        case .name(let imageName):
            guard let uiImage = UIImage(named: imageName) else {
                print("Failed to load UIImage from name")
                return
            }
            ciImage = CIImage(image: uiImage)
        case .image(let uiImage):
            ciImage = CIImage(image: uiImage)
        }

        guard let ciImage = ciImage else {
            print("Failed to create CIImage")
            return
        }

        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                print("Model failed to process image: \(error?.localizedDescription ?? "")")
                return
            }

            DispatchQueue.main.async {
                self.identifiedObjects = results
                    .sorted { $0.confidence > $1.confidence }
                    .prefix(7)
                    .map { ($0.identifier, Double($0.confidence)) }
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }

    enum ImageSource {
        case name(String)
        case image(UIImage)
    }

}

struct PaLabel: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("P")
                .bold()
                .foregroundColor(.red)
                .font(.title)
            Text("a")
                .bold()
                .foregroundColor(.red)
                .font(.system(size: 20))
                .offset(y: -5)
        }
    }
}

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
