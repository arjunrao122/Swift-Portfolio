# HealthKitHeartRateStream

This repository contains a SwiftUI-based project that demonstrates the integration of HealthKit to monitor and stream heart rate data from an Apple Watch to an iPhone in real-time. The app provides a simple and user-friendly interface to display the current heart rate and uses WatchConnectivity to communicate between the watchOS and iOS devices.

## Features

- Real-time Heart Rate Display: Shows the user's heart rate in real-time on the Apple Watch.
- HealthKit Integration: Utilizes HealthKit to access heart rate data.
- WatchConnectivity: Establishes a communication channel between the watch and the iPhone.
- Workout Emulation: Includes a functionality to start a mock workout session to read heart rate data more frequently.
- SwiftUI: Uses SwiftUI for a modern and efficient UI design.

## Getting Started

### Prerequisites

- Xcode 13 or later
- iOS 15.0 or later
- watchOS 8.0 or later
- A paired Apple Watch and iPhone

### Installation

1. Clone the repository to your local machine:
    ```sh
    git clone https://github.com/arjunrao122/Swift-Portfolio.git
    cd Swift-Portfolio/HealthKitHeartRateStream
    ```
2. Open the `.xcodeproj` file in Xcode.
3. Select your Development Team in project settings before building the application, under 'Signing & Capabilities'.
4. Build and run the app on your iPhone and paired Apple Watch.

### Configuration

Before using the app, you need to authorize HealthKit to access heart rate data. The app will prompt you for authorization when first launched.

## Usage

- Launch the app on your Apple Watch.
- Tap the heart emoji to start the workout emulation and begin monitoring your heart rate.
- Check the iPhone app to see your heart rate data received from the Apple Watch.

## How It Works

- The app uses `HKAnchoredObjectQuery` to subscribe to heart rate updates from HealthKit.
- When a new heart rate sample is received, it is processed and displayed on the watch.
- The heart rate is also sent to the paired iPhone using `WCSession`.

## Contributing

Contributions to the HealthKitHeartRateStream SwiftUI project are welcome!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/YourFeature`)
3. Commit your Changes (`git commit -m 'Add some YourFeature'`)
4. Push to the Branch (`git push origin feature/YourFeature`)
5. Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE` for more information.

## Contact

Arjun Rao - rao.arjun122@gmail.com

Project Link: [https://github.com/arjunrao122/HealthKitHeartRateStream]

## Acknowledgements

- [HealthKit](https://developer.apple.com/healthkit/)
- [WatchConnectivity](https://developer.apple.com/documentation/watchconnectivity)
- [SwiftUI](https://developer.apple.com/xcode/swiftui/)

