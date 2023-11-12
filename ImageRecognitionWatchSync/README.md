# ImageRecognitionWatchSync

## Overview
This app, built with SwiftUI, offers functionalities for object identification and text recognition from images. It also includes the capability to send data to an Apple Watch using the WatchConnectivity framework.

### Features
- Object Identification: Utilizes CoreML with the Resnet50 model to identify objects in images.
- Text Recognition: Implements Vision's `VNRecognizeTextRequest` to recognize text in images.
- Watch Connectivity: Sends emoji representations of recognized objects to a connected Apple Watch.
- Image Selection: Users can either take a new photo or choose one from the photo library.

## Installation

### Prerequisites
- Xcode 12 or later
- iOS 14 or later
- Swift 5

### Setup
1. Clone the repository to your local machine:
    ```sh
    git clone https://github.com/arjunrao122/Swift-Portfolio.git
    cd Swift-Portfolio/ImageRecognitionWatchSync
    ```
2. Open the `.xcodeproj` file in Xcode.
3. Ensure that you have the necessary provisioning profiles for running on a physical device if needed.

## Usage
- Launch the app.
- Choose the tab for either object identification or text recognition.
- Select an image from the library or capture a new image.
- View the results displayed on the screen.
- If an Apple Watch is connected, it will display an emoji related to the identified object.

## Watch Connectivity
To test the Watch Connectivity features:
1. Ensure you have a paired Apple Watch.
2. Run the watchOS target on your Apple Watch.
3. Use the app to send data to the watch.

## Contributing

Contributions to the ImageRecognitionWatchSync SwiftUI project are welcome!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/YourFeature`)
3. Commit your Changes (`git commit -m 'Add some YourFeature'`)
4. Push to the Branch (`git push origin feature/YourFeature`)
5. Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE` for more information.

## Contact

Arjun Rao - rao.arjun122@gmail.com
