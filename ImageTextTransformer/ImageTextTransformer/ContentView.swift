import SwiftUI
import Vision
import VisionKit
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var selectedFilter = "Original"
    @State private var imageName = "sample1"
    @State private var recognizedText = "Recognized text will appear here."
    @State private var filteredImage: UIImage?
    @State private var sliderValue: Float = 0.0

    private let context = CIContext()

    var body: some View {
        VStack {
            Text("TXT Recognition vs Image Filters")
                .font(.title)
                .padding()

            Picker("", selection: $selectedFilter) {
                Text("Original").tag("Original")
                Text("Blur").tag("Blur")
                Text("Binarized").tag("Binarized")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Image(uiImage: filteredImage ?? UIImage(named: imageName)!)
                .resizable()
                .scaledToFit()
                .padding()
                .onChange(of: selectedFilter) { _ in applyFilter() }
                .onChange(of: filteredImage ?? UIImage(named: imageName)) { _ in recognizeText() }

            HStack {
                Button(action: {
                    self.changeImage()
                }) {
                    Image(systemName: "photo")
                }
                .padding()

                Slider(value: $sliderValue, in: 0...300, step: 1)
                    .padding()
                    .disabled(selectedFilter == "Original")
                    .onChange(of: sliderValue) { _ in applyFilter() }

                Text("\(Int(sliderValue))%")
            }
            Text(recognizedText)
                .padding()
        }
        .onAppear(perform: {
                    recognizeText()
                    applyFilter()
                })
    }
    
    var blurRadius: Float {
        let minBlurRadius: Float = 0
        let maxBlurRadius: Float = 10
        return minBlurRadius + Float(sliderValue/300) * (maxBlurRadius - minBlurRadius)
    }

    func changeImage() {
            let imageNames = ["sample1", "sample2", "sample3"]
            if let currentImageIndex = imageNames.firstIndex(of: imageName) {
                var newImageNames = imageNames
                newImageNames.remove(at: currentImageIndex)
                imageName = newImageNames.randomElement() ?? imageName
            }
        }

    func recognizeText() {
        guard let uiImage = filteredImage ?? UIImage(named: imageName) else {
            self.recognizedText = "Failed to load image."
            return
        }
        
        guard let cgImage = uiImage.cgImage else {
            self.recognizedText = "Failed to convert image."
            return
        }
        
        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                self.recognizedText = "Error recognizing text: \(error.localizedDescription)"
                return
            }
            
            let observations = request.results as? [VNRecognizedTextObservation]
            let recognizedStrings = observations?.compactMap { observation in
                return observation.topCandidates(1).first?.string
            }
            
            DispatchQueue.main.async {
                self.recognizedText = recognizedStrings?.joined(separator: "\n") ?? ""
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            self.recognizedText = "Failed to perform text recognition."
        }
    }
    
    func applyFilter() {
            guard let inputImage = UIImage(named: imageName),
                  let ciInputImage = CIImage(image: inputImage) else {
                return
            }

            let outputCIImage: CIImage?

            switch selectedFilter {
            case "Blur":
                outputCIImage = applyBlur(to: ciInputImage)
            case "Binarized":
                outputCIImage = applyBinarization(to: ciInputImage)
            default:
                outputCIImage = ciInputImage
            }

            if let outputCIImage = outputCIImage,
               let cgImg = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
                filteredImage = UIImage(cgImage: cgImg)
            }
        }

        func applyBlur(to inputImage: CIImage) -> CIImage? {
            let blurFilter = CIFilter.gaussianBlur()
            blurFilter.radius = Float(blurRadius)
            blurFilter.inputImage = inputImage
            return blurFilter.outputImage
        }

        func applyBinarization(to inputImage: CIImage) -> CIImage? {
            let colorControlsFilter = CIFilter.colorControls()
            colorControlsFilter.inputImage = inputImage
            colorControlsFilter.saturation = 0
            colorControlsFilter.brightness = 0
            colorControlsFilter.contrast = 2
            return colorControlsFilter.outputImage
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
