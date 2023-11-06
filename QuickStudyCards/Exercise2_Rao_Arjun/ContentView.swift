import SwiftUI

struct ContentView: View {
    let logoImages: [UIImage] = [#imageLiteral(resourceName: "1"), #imageLiteral(resourceName: "2"), #imageLiteral(resourceName: "3")]


    @State private var selectedCardIndex = 0
    @State private var showActionSheet = false
    @State private var showAddBulletScreen = false
    @State private var showEditCardNameScreen = false
    @State private var newBulletText = ""
    @State private var newCardName = ""
    @State private var cardNames = ["View Controller", "UIKit", "UIAlertController"]
    @State private var bulletPointsDict: [String: [String]] = [
        "View Controller": [
            "★ View Controllers are fundamental building blocks in iOS apps.",
            "★ They manage the presentation of content on the screen.",
            "★ View Controllers can contain other view controllers.",
            "★ They are part of the UIKit framework.",
            "★ View Controllers are used for navigation and user interface management."
        ],
        "UIKit": [
            "★ UIKit is used for building user interfaces in iOS.",
            "★ It provides a set of components and controls.",
            "★ UIKit includes buttons, labels, text fields, and more.",
            "★ It offers a framework for event handling and user interactions.",
            "★ UIKit is essential for iOS app development."
        ],
        "UIAlertController": [
            "★ UIAlertController is used for showing alerts in iOS.",
            "★ It is part of the UIKit framework.",
            "★ You can display messages and get user input with it.",
            "★ UIAlertController has different styles, including alert and action sheet.",
            "★ It is commonly used for presenting important information or obtaining user feedback."
        ],
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                Text("CardHub")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(Color(red: 0.7, green: 0.0, blue: 0.0))
                
//                Image(cardNames[selectedCardIndex].lowercased())
                Image(uiImage: logoImages[selectedCardIndex])
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Card: \(cardNames[selectedCardIndex])")
                            .font(.headline)
                            .fontWeight(.heavy)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                    }
                    .background(Color.orange)
                    .frame(maxWidth: .infinity)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(bulletPointsDict[cardNames[selectedCardIndex]] ?? [], id: \.self) { point in
                            Text(point)
                                .padding(.leading, -10)
                                .padding(.bottom, 5)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 450)
                    .padding(.horizontal)
                    .background(Color.gray)
                }
                
                Button("Next Card") {
                    selectedCardIndex = (selectedCardIndex + 1) % cardNames.count
                }
                .font(.headline)
                .fontWeight(.heavy)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                
                Button("Card selector") {
                    showActionSheet = true
                }
                .font(.headline)
                .fontWeight(.heavy)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.7, green: 0.0, blue: 0.0))
                .foregroundColor(.white)
                .actionSheet(isPresented: $showActionSheet) {
                    ActionSheet(title: Text("Select a topic"), buttons: getActionSheetButtons())
                }
                
                Button("Add bullet") {
                    showAddBulletScreen = true
                }
                .font(.headline)
                .fontWeight(.heavy)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.yellow)
                .foregroundColor(.white)
                
                Button("Edit card name") {
                    showEditCardNameScreen = true
                }
                .font(.headline)
                .fontWeight(.heavy)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.yellow)
                .foregroundColor(.white)
            }
            .padding()
            .sheet(isPresented: $showAddBulletScreen) {
                NavigationView {
                    VStack {
                        Text("ADD BULLET")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(Color(red: 0.7, green: 0.0, blue: 0.0))
                        
                        VStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Card: \(cardNames[selectedCardIndex])")
                                    .font(.headline)
                                    .fontWeight(.heavy)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(.white)
                            }
                            .background(Color.orange)
                            .frame(maxWidth: .infinity)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                TextField("New bullet", text: $newBulletText)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray)
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 100)
                            .padding(.horizontal)
                            .background(Color.gray)
                        }
                            
                        Button("Save") {
                            if var currentBulletPoints = bulletPointsDict[cardNames[selectedCardIndex]] {
                                currentBulletPoints.append("★ " + newBulletText)
                                bulletPointsDict[cardNames[selectedCardIndex]] = currentBulletPoints
                            } else {
                                bulletPointsDict[cardNames[selectedCardIndex]] = ["* " + newBulletText]
                            }
                            
                            newBulletText = ""
                            showAddBulletScreen = false
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.7, green: 0.0, blue: 0.0))
                        .foregroundColor(.white)
                        
                        Button("Cancel") {
                            showAddBulletScreen = false
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding()
                }
            }

            .sheet(isPresented: $showEditCardNameScreen) {
                NavigationView {
                    VStack {
                        Text("EDIT TOPIC")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(Color(red: 0.7, green: 0.0, blue: 0.0))
                        
                        VStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Card: \(cardNames[selectedCardIndex])")
                                    .font(.headline)
                                    .fontWeight(.heavy)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(.white)
                            }
                            .background(Color.orange)
                            .frame(maxWidth: .infinity)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                TextField("New card name", text: $newCardName)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray)
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 100)
                            .padding(.horizontal)
                            .background(Color.gray)
                        }
                        
                        Button("Save") {
                            if !newCardName.isEmpty {
                                let oldCardName = cardNames[selectedCardIndex]
                                cardNames[selectedCardIndex] = newCardName

                                if let bulletPoints = bulletPointsDict[oldCardName] {
                                    bulletPointsDict[newCardName] = bulletPoints
                                    bulletPointsDict.removeValue(forKey: oldCardName)
                                }
                            }
                            
                            showEditCardNameScreen = false
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.7, green: 0.0, blue: 0.0))
                        .foregroundColor(.white)
                        
                        Button("Cancel") {
                            showEditCardNameScreen = false
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }
    
    func getNextCardState(from currentCardIndex: Int) -> Int {
        let totalCards = cardNames.count
        let nextIndex = (currentCardIndex + 1) % totalCards
        return nextIndex
    }
    
    func getActionSheetButtons() -> [ActionSheet.Button] {
            return cardNames.map { cardName in
                .default(Text(cardName)) {
                    if let index = cardNames.firstIndex(of: cardName) {
                        selectedCardIndex = index
                    }
                }
            } + [.cancel()]
        }
    }

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
