import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var betAmount = 1
    @State private var creditAmount = 100
    @State private var showAlert = false
    @State private var inputText = ""
    @State private var grid = Array(repeating: "questionmark", count: 9)
    @State private var isGameStarted = false
    let columns = [GridItem(), GridItem(), GridItem()]
    @State private var spins = 0
    @State private var won = 0
    @State private var showingAlert = false
    @State private var playCount = 0
    
    private func playGame() {
            for index in grid.indices {
                grid[index] = Bool.random() ? "circle_black" : "cross_black"
            }
            
            checkForWin()
        }
        
    private func checkForWin() {
            let winPatterns: [[Int]] = [
                [0, 1, 2], [3, 4, 5], [6, 7, 8],
                [0, 3, 6], [1, 4, 7], [2, 5, 8],
                [0, 4, 8], [2, 4, 6]
            ]
            
            var wonFlag = false
            
        for pattern in winPatterns {
            let symbols = pattern.map { grid[$0] }
            if let winSymbol = symbols.first, symbols.allSatisfy({ $0 == winSymbol }) {
                let replacementSymbol = winSymbol == "circle_black" ? "circle_red" : "cross_red"
                pattern.forEach { grid[$0] = replacementSymbol }
                
                creditAmount -= betAmount
                betAmount = 1
                spins += 1
                wonFlag = true
                
                return
            }
        }
            
            if !wonFlag {
                creditAmount += betAmount
                betAmount = 1
                spins += 1
                won += 10 * betAmount
            }
        }
    
    var body: some View {
        VStack {
            Text("!XO in a row")
                .font(.custom("GillSans-Bold", size: 50))
                .foregroundColor(.orange)
                .padding()
            
            TabView(selection: $selectedTab) {
                NavigationView {
                    VStack {
                        HStack {
                            Spacer()
                            Text("Credit: \(creditAmount)")
                                .font(.custom("GillSans", size: 40))
                            Spacer()
                            Text("Bet: \(betAmount)")
                                .font(.custom("GillSans", size: 40))
                            Spacer()
                        }
                        .padding(.top)
                        
                        VStack {
                            LazyVGrid(columns: columns, spacing: 10) {
                                ForEach(0..<9) { index in
                                    if grid[index] == "questionmark" {
                                        Image(systemName: grid[index])
                                            .resizable()
                                            .foregroundColor(.blue)
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 115, height: 115)
                                    } else {
                                        Image(grid[index])
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    }
                                }
                            }
                        }
                        .padding()
                        HStack {
                            Spacer()
                            
                            ZStack {
                                Button(action: {
                                    if betAmount > creditAmount {
                                        showingAlert = true
                                    } else {
                                        playGame()
                                    }
                                }) {
                                    Text("Play")
                                        .font(.custom("GillSans", size: 40))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background(Color.blue)
                                }
                                .alert(isPresented: $showingAlert) {
                                    Alert(
                                        title: Text("Not enough credit!"),
                                        message: Text("\nPlease add more credit at the bank tab."),
                                        dismissButton: .default(Text("OK"))
                                    )
                                }
                            }
                            
                            Spacer()
                            
                            ZStack {
                                Button(action: {
                                    if betAmount < creditAmount {
                                        betAmount += 1
                                    } else {
                                        showAlert = true
                                        betAmount = 1
                                    }
                                }) {
                                    Text("↑ Bet")
                                        .font(.custom("GillSans", size: 40))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background(Color.blue)
                                }
                                .alert(isPresented: $showAlert) {
                                    Alert(
                                        title: Text("Bet Amount Exceeded!"),
                                        message: Text("\nBet amount has been reset."),
                                        dismissButton: .default(Text("OK"))
                                    )
                                }
                            }
                            
                            Spacer()
                        }
                        .frame(height: 100)
                        .padding(.bottom)
                        .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text("Not enough credit!"),
                                message: Text("\nPlease add more credit at the bank tab."),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    }
                }
                .tabItem {
                    VStack {
                        Image(systemName: "seal.fill")
                        Text("Game")
                    }
                }
                .tag(0)
                
                NavigationView {
                    VStack {
                        HStack {
                            Text("Spins:")
                                .font(.custom("GillSans", size: 40))
                            Spacer()
                            Text("\(spins)")
                                .font(.custom("GillSans", size: 40))
                        }
                        .padding()
                        
                        HStack {
                            Text("Won:")
                                .font(.custom("GillSans", size: 40))
                            Spacer()
                            Text("\(won)")
                                .font(.custom("GillSans", size: 40))
                        }
                        .padding()
                        
                        HStack {
                            Text("Credit:")
                                .font(.custom("GillSans", size: 40))
                            Spacer()
                            Text("\(creditAmount)")
                                .font(.custom("GillSans", size: 40))
                        }
                        .padding()
                        HStack {
                            TextField("0", text: $inputText)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.custom("GillSans", size: 40))
                                .padding()
                            Text("$")
                                .font(.custom("GillSans", size: 40))
                                .padding()
                        }
                        ZStack {
                            Rectangle()
                                .fill(Color.blue)
                            Button("Add credit") {
                                // Handle add credit button tap here
                                if let addedCredit = Int(inputText) {
                                    creditAmount += addedCredit
                                    inputText = ""
                                }
                            }
                            .font(.custom("GillSans", size: 40))
                            .foregroundColor(.white)
                        }
                        .frame(height: 100)
                        .padding()
                    }
                }
                .tabItem {
                    VStack {
                        Image(systemName: "banknote.fill")
                        Text("Bank")
                    }
                }
                .tag(1)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
