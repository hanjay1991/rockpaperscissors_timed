//
//  ContentView.swift
//  RockPaperScissors
//
//  Created by Jay Hanley on 5/18/26.
//

import SwiftUI
import Combine

struct ButtonView: View {
    var name: String
    
    var body: some View {
        Text(name)
            .font(.title)
            .foregroundStyle(Color.white)
            .shadow(radius: 5)
    }
}

struct ContentView: View {
    private var choices = ["Rock", "Paper", "Scissors"]
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    @State private var yourPossibleChoice: Int?
    
    @State private var NPCchoice = Int.random(in: 0...2)
    @State private var shouldWin: Bool = Bool.random()
    
    @State private var scoreTitle = ""
    
    @State private var currentScore = 0
    @State private var currentQuestion = 1
    
    @State private var showingScore = false
    @State private var startGame = true
    @State private var endGame = false
    
    @State private var stopWatch: Double = 0
    @State private var fastestTime: Double?
    
    var body: some View {
        ZStack {
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45),location:0.3),
                .init(color:Color(red:0.76, green: 0.15, blue: 0.26),location: 0.3),
            ], center: .top, startRadius: 200, endRadius:400)
            .ignoresSafeArea()
            VStack {
                Text("")
                Text("App move: \(choices[NPCchoice])")
                    .font(.title)
                    .foregroundStyle(.white)
                    .shadow(color: .black, radius: 5, x: 5, y: 5)
                Text("Should you win? \(shouldWin ? "Yes" : "No")")
                    .font(.title)
                    .foregroundStyle(.white)
                    .shadow(color: .black, radius: 5, x: 5, y: 5)
                Spacer()
                Text("Tap your choice:")
                    .font(.largeTitle)
                    .padding()
                VStack(alignment: .center, spacing: 20) {
                    VStack(spacing:20) {
                        ForEach(0..<3) { number in
                            Button {
                                yourPossibleChoice = number
                                choiceTapped(doesEarnPoints: doesEarnPoints())
                                showingScore = true
                            } label: {
                                ButtonView(name: choices[number])
                            }
                        }
                    }
                }
                .alert("Start game?", isPresented: $startGame) {
                    Button("Start",action: startTimer)
                }
                .alert(scoreTitle, isPresented: $showingScore) {
                    Button("Continue",action: nextRound)
                } message: {
                    Text("Your score is \(currentScore)")
                }
                
                .alert("Game Over, you've earned \(currentScore) points.", isPresented: $endGame) {
                    Button("Restart?",action: reset)
                } message : {
                    Text("This round's time was \(String(format: "%.2f", stopWatch)) seconds and your fastest time is \(String(format: "%.2f", fastestTime ?? stopWatch))s")
                }
                .onReceive(timer) { _ in
                     if startGame == false && showingScore == false && endGame == false {
                        stopWatch += 0.01
                    }
                }
                Spacer()
                Text("Current question: \(currentQuestion) /10")
                Text("Current score: \(currentScore)")
                Text("Timer: \(String(format: "%.2f", stopWatch))s")
                if let fastestTime = fastestTime {
                    Text("Fastest time: \(String(format: "%.2f", fastestTime))s")
                } else {
                    Text("No fastest time yet")
                }
            }
            .padding()
            
        }
        
    }
    func startTimer() {
        startGame = false
    }
    
    func willBeat() -> Bool {
        let yourChoice:String = choices[yourPossibleChoice ?? 0]
        let NPCStringChoice: String = choices[NPCchoice]
        if yourChoice == NPCStringChoice {
            return false
        } else if yourChoice == "Rock" && NPCStringChoice == "Scissors" {
            return true
        } else if yourChoice == "Paper" && NPCStringChoice == "Rock" {
            return true
        } else if yourChoice == "Scissors" && NPCStringChoice == "Paper" {
            return true
        } else {
            return false
        }
        
    }
    func doesEarnPoints() -> Bool {
        let yourChoice = choices[yourPossibleChoice ?? 0]
        let NPCStringChoice = choices[NPCchoice]
        if yourChoice == NPCStringChoice {
            return false
        } else if willBeat() == true && shouldWin == true {
            return true
        } else if willBeat() == false && shouldWin == false {
            return true
        }
        return false
    }
    func choiceTapped(doesEarnPoints: Bool) {
        let earnedPoints = doesEarnPoints
        if earnedPoints {
            scoreTitle = "You won this round!"
            currentScore += 1
        } else {
            scoreTitle = "You lost this round."
            if currentScore > 0 {
                currentScore -= 1
            } else {
                currentScore = 0
            }
        }
    }
    func nextRound() {
        shouldWin.toggle()
        NPCchoice = Int.random(in: 0...2)
        
        if currentQuestion == 10 {
            endGame = true
            if stopWatch < (fastestTime ?? Double.infinity) {
                fastestTime = stopWatch
            }
        } else {
            showingScore = false
            currentQuestion += 1
        }
    }
    func reset() {
        currentQuestion = 1
        currentScore = 0
        showingScore = false
        endGame = false
        stopWatch = 0
    }
}

#Preview {
    ContentView()
}
