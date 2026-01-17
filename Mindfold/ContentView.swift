//
//  ContentView.swift
//  Mindfold
//
//  Created by Evan Haque on 1/9/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameData = GameData()
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dark background
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HeaderView(onSettingsTap: {
                        showSettings = true
                    })
                    
                    // Game list
                    ScrollView {
                        VStack(spacing: 24) {
                            // Main games
                            VStack(spacing: 16) {
                                ForEach(gameData.games) { game in
                                    NavigationLink(destination: destinationView(for: game)) {
                                        GameCard(
                                            title: game.title,
                                            description: game.description,
                                            color: game.color,
                                            icon: AnyView(GameIconView(game: game))
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.bottom, 20)
                        }
                        .padding(.top, 0)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for game: Game) -> some View {
        switch game.title {
        case "Shikaku":
            ShikakuGameView()
        case "Takuzu":
            TakuzuGameView()
        case "Star Battle":
            StarBattleGameView()
        case "Netwalk":
            NetwalkGameView()
        case "LITS":
            LITSGameView()
        case "Mastermind":
            MastermindGameView()
        case "Flood Fill":
            FloodfillGameView()
        case "Bridges":
            BridgesGameView()
        case "Number Snake":
            NumberSnakeGameView()
        default:
            // Placeholder for other games
            Text("\(game.title) game coming soon")
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ContentView()
}
