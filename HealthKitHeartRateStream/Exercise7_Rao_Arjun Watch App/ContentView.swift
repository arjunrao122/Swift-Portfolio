import SwiftUI
import HealthKit

struct ContentView: View {
    @State private var heartRate: Double = 0.0
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    private let healthStore = HKHealthStore()

    var time: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Text("")
                        .padding([.top, .trailing])
                }
                
                Button(action: {
                    createWorkoutEmulation()
                }) {
                    Text("❤️")
                        .font(.system(size: 50))
                }
                
                HStack(alignment: .top, spacing: 10) {
                    Text("\(Int(heartRate))")
                        .font(.system(size: 70, weight: .regular))
                    
                    Text("BPM")
                        .font(.system(size: 28, weight: .bold))
                        .font(.headline)
                        .offset(y: +10)
                        .foregroundColor(.red)
                    
                    Spacer()
                }
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: start)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func start() {
        authorizeHealthKit()
        startHeartRateQuery(quantityTypeIdentifier: .heartRate)
    }
    
    private func authorizeHealthKit() {
        let healthKitTypes: Set = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]

        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { success, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.alertMessage = "HealthKit Authorization Failed: \(error.localizedDescription)"
                    self.showAlert = true
                }
                return
            }

            if !success {
                DispatchQueue.main.async {
                    self.alertMessage = "HealthKit Authorization was not successful. Please allow access to proceed."
                    self.showAlert = true
                }
            }
        }
    }

    
    private func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {

        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])

        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            query, samples, deletedObjects, queryAnchor, error in

            guard let samples = samples as? [HKQuantitySample] else {
                return
            }

            self.process(samples, type: quantityTypeIdentifier)
        }

        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)

        query.updateHandler = updateHandler

        healthStore.execute(query)
    }

    private func createWorkoutEmulation() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .outdoor

        let healthStore = HKHealthStore()
        var session: HKWorkoutSession!
        var builder: HKWorkoutBuilder!

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session.associatedWorkoutBuilder()
        } catch {
            return
        }
        session.startActivity(with: Date())
        builder.beginCollection(withStart: Date()) { (success, error) in
        }
    }

    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        var lastHeartRate = 0.0

        let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())

        for sample in samples {
            if type == .heartRate {
                lastHeartRate = sample.quantity.doubleValue(for: heartRateUnit)
            }
        }
        self.heartRate = lastHeartRate
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
