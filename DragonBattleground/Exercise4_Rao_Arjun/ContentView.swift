import SwiftUI
import GameplayKit
import AudioToolbox


struct ContentView: View {
    @State private var selectedTab = "Game"
    @State private var player1Dragon = "0_HOD_logo"
    @State private var player2Dragon = "0_HOD_logo"
    @State private var battleMessage = "Prepare for the battle!"
    @State private var player1Wins = 0
    @State private var player2Wins = 0
    @State private var showWinningAnimation1: Bool = false
    @State private var showWinningAnimation2: Bool = false

    
    let dragons = ["Balerion", "Meraxes", "Sheepstealer", "Silverwing", "Meleys", "Quicksilver", "Stormcloud", "Drogon", "Viserion"]
    let dragonStrength: [String: Int] = ["Balerion": 9, "Meraxes": 8, "Sheepstealer": 7, "Silverwing": 6, "Meleys": 5, "Quicksilver": 4, "Stormcloud": 3, "Drogon": 2, "Viserion": 1]
    
    func fight() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            AudioServicesPlaySystemSound(1000)
            var availableDragons = dragons
            player1Dragon = availableDragons.randomElement()!
            availableDragons.removeAll { $0 == player1Dragon }
            player2Dragon = availableDragons.randomElement()!
            
            let player1Strength = dragonStrength[player1Dragon]!
            let player2Strength = dragonStrength[player2Dragon]!
            
            if player1Strength > player2Strength {
                player1Wins += 1
            } else {
                player2Wins += 1
            }
            
            if player1Wins >= 3 {
                withAnimation {
                    showWinningAnimation1.toggle()
                }
                battleMessage = "Player 1 won! \(player1Wins) - \(player2Wins)\nRestart the game."
            } else if player2Wins >= 3 {
                withAnimation {
                    showWinningAnimation2.toggle()
                }
                battleMessage = "Player 2 won! \(player1Wins) - \(player2Wins)\nRestart the game."
            } else {
                battleMessage = "\(player1Strength > player2Strength ? player1Dragon : player2Dragon) is stronger.\nPlayer \(player1Strength > player2Strength ? 1 : 2) wins the round!"
            }
        }
    }
    
    func restartGame() {
            player1Wins = 0
            player2Wins = 0
            battleMessage = "Prepare for the battle!"
            player1Dragon = "0_HOD_logo"
            player2Dragon = "0_HOD_logo"
        }
    
    var body: some View {
        VStack {
            Image("0_HOD_text")
                .resizable()
                .scaledToFit()
                .frame(height: 100)
            
            if selectedTab == "Game" {
                HStack {
                    Spacer()
                    
                    VStack {
                        Text("Player 1")
                            .font(.title)
                            .foregroundColor(Color(red: 0.45, green: 0.29, blue: 0.08))
                        Image(player1Dragon)
                            .resizable()
                            .frame(width: 120, height: 120)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("Player 2")
                            .font(.title)
                            .foregroundColor(Color(red: 0.45, green: 0.29, blue: 0.08))
                        Image(player2Dragon)
                            .resizable()
                            .frame(width: 120, height: 120)
                    }
                    
                    Spacer()
                }
                
                VStack {
                    if showWinningAnimation1 {
                        Spacer()
                        Text(battleMessage)
                            .scaleEffect(showWinningAnimation1 ? 2 : 1)
                            .animation(Animation.spring(response: 2.0, dampingFraction: 1.6, blendDuration: 2.0).delay(1).repeatForever(autoreverses: true), value: showWinningAnimation1)
                            .foregroundColor(Color(red: 0.45, green: 0.29, blue: 0.08))
                        Spacer()
                    }
                    else if showWinningAnimation2 {
                        Spacer()
                        Text(battleMessage)
                            .scaleEffect(showWinningAnimation2 ? 2 : 1)
                            .animation(Animation.spring(response: 2.0, dampingFraction: 1.6, blendDuration: 2.0).delay(1).repeatForever(autoreverses: true), value: showWinningAnimation2)
                            .foregroundColor(Color(red: 0.45, green: 0.29, blue: 0.08))
                        Spacer()
                    }
                    else {
                        Text(battleMessage)
                            .font(.title)
                            .foregroundColor(Color(red: 0.45, green: 0.29, blue: 0.08))
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                    }
                }
                .padding(.horizontal)

                HStack {
                    Spacer()
                    
                    VStack {
                        Spacer()
                        Text("Restart")
                            .font(.title)
                            .foregroundColor(Color(red: 0.45, green: 0.29, blue: 0.08))
                        Image("0_refresh_arrows")
                            .resizable()
                            .frame(width: 120, height: 120)
                        Spacer()
                    }
                    .onTapGesture {
                        restartGame()
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("Fight")
                            .font(.title)
                            .foregroundColor(Color(red: 0.45, green: 0.29, blue: 0.08))
                        Image("0_crossing-swords")
                            .resizable()
                            .frame(width: 120, height: 120)
                    }
                    .onTapGesture {
                        fight()
                    }
                    .disabled(player1Wins >= 3 || player2Wins >= 3)
                    Spacer()
                }
                .padding(.horizontal)

            } else {
                VStack {
                    VStack {
                        Text("Player 1")
                            .font(.system(size: 36))
                            .foregroundColor(Color.brown)
                        
                        HStack {
                            ForEach(0..<3) { index in
                                Image("0_HOD_logo")
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .opacity(index < player1Wins ? 1.0 : 0.5)
                            }
                        }
                    }
                    
                    VStack {
                        Text("Player 2")
                            .font(.system(size: 36))
                            .foregroundColor(Color.brown)
                        
                        HStack {
                            ForEach(0..<3) { index in
                                Image("0_HOD_logo")
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .opacity(index < player2Wins ? 1.0 : 0.5)
                            }
                        }
                    }
                }
            }
            
            Spacer()
                    
            HStack {
                Spacer()
                
                Button(action: {
                    selectedTab = "Game"
                }) {
                    VStack {
                        Image(selectedTab == "Game" ? "0_fire_on" : "0_fire_off")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("Game")
                            .font(.caption)
                            .foregroundColor(selectedTab == "Game" ? .blue : .black)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    selectedTab = "Score"
                }) {
                    VStack {
                        Image(selectedTab == "Score" ? "0_score_on" : "0_score_off")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("Score")
                            .font(.caption)
                            .foregroundColor(selectedTab == "Score" ? .blue : .black)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
